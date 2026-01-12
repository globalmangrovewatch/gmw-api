class ProcessAlertSyncJob < ApplicationJob
  include AlertFetcher

  queue_as :default

  def perform(sync_run_id)
    @sync_run = AlertSyncRun.find_by(id: sync_run_id)
    return unless @sync_run

    Rails.logger.info "[ProcessAlertSyncJob] Starting sync run #{sync_run_id}"
    @sync_run.start!

    process_system_locations
    process_custom_locations

    @sync_run.complete!(
      system_locations_checked: @sync_run.system_locations_checked,
      custom_locations_checked: @sync_run.custom_locations_checked,
      notifications_sent: @sync_run.notifications_sent
    )

    Rails.logger.info "[ProcessAlertSyncJob] Sync run #{sync_run_id} completed"
  rescue => e
    Rails.logger.error "[ProcessAlertSyncJob] Sync run #{sync_run_id} failed: #{e.message}"
    @sync_run&.fail!(e.message)
    raise
  end

  private

  def process_system_locations
    system_location_ids = UserLocation.alertable
      .system_locations
      .distinct
      .pluck(:location_id)
      .compact

    Rails.logger.info "[ProcessAlertSyncJob] Processing #{system_location_ids.count} system locations"

    system_location_ids.each do |location_id|
      check_system_location(location_id)
    end
  end

  def check_system_location(location_id)
    response_data = fetch_alerts_by_id(location_id)
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_for_system(location_id)
    new_dates = snapshot.persisted? ? snapshot.new_dates_in(response_data) : []

    if new_dates.any?
      Rails.logger.info "[ProcessAlertSyncJob] New dates for #{location_id}: #{new_dates.join(", ")}"

      users_to_notify = User.joins(:user_locations)
        .where(user_locations: {location_id: location_id, alerts_enabled: true})
        .where(subscribed_to_location_alerts: true)
        .distinct

      users_to_notify.each do |user|
        NotifyLocationAlertJob.perform_later(
          user_id: user.id,
          location_name: location_name_for(location_id),
          new_dates: new_dates
        )
        @sync_run.increment_stat!(:notifications_sent)
      end
    end

    snapshot.update_from_response!(response_data)
    @sync_run.increment_stat!(:system_locations_checked)
  rescue => e
    Rails.logger.error "[ProcessAlertSyncJob] Error checking system location #{location_id}: #{e.message}"
    @sync_run.add_error!("System location #{location_id}: #{e.message}")
  end

  def process_custom_locations
    custom_user_locations = UserLocation.alertable.custom_locations

    Rails.logger.info "[ProcessAlertSyncJob] Processing #{custom_user_locations.count} custom locations"

    custom_user_locations.find_each do |user_location|
      CheckCustomLocationAlertJob.perform_later(
        user_location_id: user_location.id,
        sync_run_id: @sync_run.id
      )
    end
  end

  def location_name_for(location_id)
    Location.find_by(location_id: location_id)&.name ||
      Location.find_by(iso: location_id)&.name ||
      location_id
  end
end

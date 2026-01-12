class CheckCustomLocationAlertJob < ApplicationJob
  include AlertFetcher

  queue_as :default

  def perform(user_location_id:, sync_run_id:)
    @sync_run = AlertSyncRun.find_by(id: sync_run_id)
    user_location = UserLocation.find_by(id: user_location_id)

    return unless user_location
    return unless user_location.custom_location? || user_location.test_location?
    return unless user_location.alerts_enabled?
    return unless user_location.user&.subscribed_to_location_alerts?

    location_type = user_location.test_location? ? "test" : "custom"
    Rails.logger.info "[CheckCustomLocationAlertJob] Checking #{location_type} location #{user_location_id}"

    response_data = if user_location.test_location?
      fetch_alerts_by_id(user_location.test_location_id)
    else
      fetch_alerts_with_geometry(user_location.geometry_feature_collection)
    end
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_for_custom(user_location)
    new_dates = snapshot.persisted? ? snapshot.new_dates_in(response_data) : []

    if new_dates.any?
      Rails.logger.info "[CheckCustomLocationAlertJob] New dates for #{location_type} location #{user_location_id}: #{new_dates.join(", ")}"

      NotifyLocationAlertJob.perform_later(
        user_id: user_location.user_id,
        location_name: user_location.name,
        new_dates: new_dates
      )
      @sync_run&.increment_stat!(:notifications_sent)
    end

    snapshot.update_from_response!(response_data)
    @sync_run&.increment_stat!(:custom_locations_checked)
  rescue => e
    Rails.logger.error "[CheckCustomLocationAlertJob] Error for user_location #{user_location_id}: #{e.message}"
    @sync_run&.add_error!("Custom location #{user_location_id}: #{e.message}")
  end
end

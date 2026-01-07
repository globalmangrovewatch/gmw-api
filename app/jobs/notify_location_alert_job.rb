class NotifyLocationAlertJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform(location_id:, new_dates:, latest_count: nil)
    Rails.logger.info "[NotifyLocationAlertJob] Sending alerts for location #{location_id}, dates: #{new_dates}"

    users = find_users_for_location(location_id)
    Rails.logger.info "[NotifyLocationAlertJob] Found #{users.count} users to notify"

    location_name = resolve_location_name(location_id)

    users.find_each do |user|
      send_notification(user, location_id, location_name, new_dates, latest_count)
    end

    Rails.logger.info "[NotifyLocationAlertJob] Completed for location #{location_id}"
  end

  private

  def find_users_for_location(location_id)
    User.where(subscribed_to_location_alerts: true)
        .joins(:user_locations)
        .where(user_locations: {alerts_enabled: true, location_id: location_id})
        .distinct
  end

  def resolve_location_name(location_id)
    return "Worldwide" if location_id == "worldwide"

    location = Location.find_by(location_id: location_id) || Location.find_by(id: location_id)
    location&.name || "Location #{location_id}"
  end

  def send_notification(user, location_id, location_name, new_dates, latest_count)
    NotificationMailer.location_alert_email(
      user: user,
      location_id: location_id,
      location_name: location_name,
      new_dates: new_dates,
      latest_count: latest_count
    ).deliver_later
  rescue => e
    Rails.logger.error "[NotifyLocationAlertJob] Failed to send to #{user.email}: #{e.message}"
  end
end


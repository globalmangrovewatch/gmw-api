class NotifyLocationAlertJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform(user_id:, location_name:, new_dates:)
    user = User.find_by(id: user_id)
    return unless user

    Rails.logger.info "[NotifyLocationAlertJob] Sending alert to #{user.email} for #{location_name}"

    NotificationMailer.location_alert_email(
      user: user,
      location_name: location_name,
      new_dates: new_dates
    ).deliver_later

    Rails.logger.info "[NotifyLocationAlertJob] Sent alert to #{user.email}"
  rescue => e
    Rails.logger.error "[NotifyLocationAlertJob] Failed to send to #{user&.email}: #{e.message}"
    raise
  end
end

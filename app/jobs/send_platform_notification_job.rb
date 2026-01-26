class SendPlatformNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform(platform_notification_id)
    notification = PlatformNotification.find_by(id: platform_notification_id)
    return if notification.blank? || !notification.published?

    Rails.logger.info "[SendPlatformNotificationJob] Sending notification #{notification.id}: #{notification.title}"

    subscribers = find_subscribers(notification)
    Rails.logger.info "[SendPlatformNotificationJob] Found #{subscribers.count} subscribers"

    subscribers.find_each do |user|
      send_notification_to_user(user, notification)
    end

    Rails.logger.info "[SendPlatformNotificationJob] Completed sending notification #{notification.id}"
  end

  private

  def find_subscribers(notification)
    case notification.notification_type
    when "newsletter"
      User.where(subscribed_to_newsletter: true)
    when "platform_update"
      User.where(subscribed_to_platform_updates: true)
    else
      User.none
    end
  end

  def send_notification_to_user(user, notification)
    NotificationMailer.platform_notification_email(
      user: user,
      notification: notification
    ).deliver_later
  rescue => e
    Rails.logger.error "[SendPlatformNotificationJob] Failed to send to #{user.email}: #{e.message}"
  end
end


class PlatformNotification < ApplicationRecord
  belongs_to :created_by, class_name: "AdminUser", optional: true

  enum :notification_type, {
    platform_update: "platform_update",
    newsletter: "newsletter"
  }, prefix: true

  validates :title, presence: true
  validates :content, presence: true
  validates :notification_type, presence: true

  after_save :queue_notification_delivery, if: :should_send_notifications?

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :draft, -> { where(published_at: nil) }
  scope :scheduled, -> { where("published_at > ?", Time.current) }
  scope :newsletters, -> { where(notification_type: "newsletter") }
  scope :platform_updates, -> { where(notification_type: "platform_update") }
  scope :recent, -> { order(published_at: :desc) }
  scope :unsent, -> { where(sent_at: nil) }

  def published?
    published_at.present? && published_at <= Time.current
  end

  def draft?
    published_at.nil?
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def sent?
    sent_at.present?
  end

  def status
    return "draft" if draft?
    return "scheduled" if scheduled?
    "published"
  end

  def send_to_subscribers!
    return false unless published? && !sent?

    SendPlatformNotificationJob.perform_later(id)
    update_column(:sent_at, Time.current)
    true
  end

  private

  def should_send_notifications?
    published? && !sent? && saved_change_to_published_at?
  end

  def queue_notification_delivery
    SendPlatformNotificationJob.perform_later(id)
    update_column(:sent_at, Time.current)
  end
end

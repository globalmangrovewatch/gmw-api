class PlatformNotification < ApplicationRecord
  belongs_to :created_by, class_name: "AdminUser", optional: true

  enum :notification_type, {
    platform_update: "platform_update",
    newsletter: "newsletter"
  }, prefix: true

  validates :title, presence: true
  validates :content, presence: true
  validates :notification_type, presence: true

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :draft, -> { where(published_at: nil) }
  scope :scheduled, -> { where("published_at > ?", Time.current) }
  scope :newsletters, -> { where(notification_type: "newsletter") }
  scope :platform_updates, -> { where(notification_type: "platform_update") }
  scope :recent, -> { order(published_at: :desc) }

  def published?
    published_at.present? && published_at <= Time.current
  end

  def draft?
    published_at.nil?
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def status
    return "draft" if draft?
    return "scheduled" if scheduled?
    "published"
  end
end

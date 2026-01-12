class LocationAlertSnapshot < ApplicationRecord
  belongs_to :user_location, optional: true

  validate :location_id_or_user_location_present
  validates :location_id, uniqueness: true, allow_nil: true
  validates :user_location_id, uniqueness: true, allow_nil: true

  scope :for_system_locations, -> { where.not(location_id: nil) }
  scope :for_custom_locations, -> { where.not(user_location_id: nil) }

  def self.for_location(location_id)
    find_by(location_id: location_id)
  end

  def self.for_user_location(user_location)
    find_by(user_location_id: user_location.id)
  end

  def self.find_or_initialize_for_system(location_id)
    find_or_initialize_by(location_id: location_id)
  end

  def self.find_or_initialize_for_custom(user_location)
    find_or_initialize_by(user_location_id: user_location.id)
  end

  def system_location?
    location_id.present?
  end

  def custom_location?
    user_location_id.present?
  end

  def dates_from_response
    return [] if last_response.blank?

    last_response.map { |entry| entry.dig("date", "value") }.compact.sort
  end

  def update_from_response!(response_data)
    dates = response_data.map { |entry| entry.dig("date", "value") }.compact.sort
    latest = dates.last

    update!(
      latest_date: latest ? Date.parse(latest) : nil,
      date_count: dates.count,
      last_response: response_data,
      last_checked_at: Time.current
    )
  end

  def new_dates_in(response_data)
    current_dates = dates_from_response.to_set
    new_response_dates = response_data.map { |entry| entry.dig("date", "value") }.compact

    new_response_dates.reject { |d| current_dates.include?(d) }.sort
  end

  private

  def location_id_or_user_location_present
    if location_id.blank? && user_location_id.blank?
      errors.add(:base, "Either location_id or user_location_id must be present")
    end
    if location_id.present? && user_location_id.present?
      errors.add(:base, "Cannot have both location_id and user_location_id")
    end
  end
end

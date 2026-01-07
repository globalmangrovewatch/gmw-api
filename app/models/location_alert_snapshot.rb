class LocationAlertSnapshot < ApplicationRecord
  validates :location_id, presence: true, uniqueness: true

  def self.locations_to_check
    UserLocation.where(alerts_enabled: true)
                .joins(:user)
                .where(users: {subscribed_to_location_alerts: true})
                .distinct
                .pluck(:location_id)
                .compact
                .uniq
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
end

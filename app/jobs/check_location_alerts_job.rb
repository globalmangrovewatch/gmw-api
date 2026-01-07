class CheckLocationAlertsJob < ApplicationJob
  queue_as :default

  ALERTS_ENDPOINT = ENV.fetch(
    "ALERTS_ENDPOINT_URL",
    "https://us-central1-mangrove-atlas-246414.cloudfunctions.net/fetch-alerts"
  )

  def perform
    Rails.logger.info "[CheckLocationAlertsJob] Starting location alerts check..."

    locations = locations_to_check
    Rails.logger.info "[CheckLocationAlertsJob] Checking #{locations.count} locations"

    locations.each do |location_id|
      check_location(location_id)
    end

    Rails.logger.info "[CheckLocationAlertsJob] Completed"
  end

  private

  def locations_to_check
    location_ids = LocationAlertSnapshot.locations_to_check
    location_ids << "worldwide" unless location_ids.include?("worldwide")
    location_ids
  end

  def check_location(location_id)
    Rails.logger.info "[CheckLocationAlertsJob] Checking location: #{location_id}"

    response_data = fetch_alerts(location_id)
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_by(location_id: location_id)
    new_dates = snapshot.persisted? ? snapshot.new_dates_in(response_data) : []

    if new_dates.any?
      Rails.logger.info "[CheckLocationAlertsJob] New dates found for #{location_id}: #{new_dates.join(", ")}"
      NotifyLocationAlertJob.perform_later(
        location_id: location_id,
        new_dates: new_dates,
        latest_count: response_data.find { |e| e.dig("date", "value") == new_dates.last }&.dig("count")
      )
    end

    snapshot.update_from_response!(response_data)
  rescue => e
    Rails.logger.error "[CheckLocationAlertsJob] Error checking #{location_id}: #{e.message}"
  end

  def fetch_alerts(location_id)
    response = HTTParty.get(
      ALERTS_ENDPOINT,
      query: {location_id: location_id},
      timeout: 30,
      headers: {"Accept" => "application/json"}
    )

    if response.success?
      parsed = response.parsed_response
      parsed.is_a?(Array) ? parsed : []
    else
      Rails.logger.error "[CheckLocationAlertsJob] Failed to fetch #{location_id}: #{response.code}"
      []
    end
  rescue => e
    Rails.logger.error "[CheckLocationAlertsJob] HTTP error for #{location_id}: #{e.message}"
    []
  end
end


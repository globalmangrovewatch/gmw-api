module AlertFetcher
  extend ActiveSupport::Concern

  EXTERNAL_ENDPOINT = ENV.fetch(
    "ALERTS_ENDPOINT_URL",
    "https://us-central1-mangrove-atlas-246414.cloudfunctions.net/fetch-alerts"
  )

  def fetch_alerts_by_id(location_id)
    if TestAlertData.test_location?(location_id)
      fetch_test_alerts(location_id)
    else
      fetch_external_alerts_by_id(location_id)
    end
  end

  def fetch_alerts_with_geometry(geometry, user_location_id: nil)
    fetch_external_alerts_with_geometry(geometry)
  end

  private

  def fetch_test_alerts(location_id)
    test_data = TestAlertData.for_location(location_id)
    test_data.as_response
  rescue => e
    Rails.logger.error "[AlertFetcher] Error fetching test data for #{location_id}: #{e.message}"
    []
  end

  def fetch_external_alerts_by_id(location_id)
    response = HTTParty.get(
      EXTERNAL_ENDPOINT,
      query: {location_id: location_id},
      timeout: 30,
      headers: {"Accept" => "application/json"}
    )

    parse_response(response, "location_id=#{location_id}")
  end

  def fetch_external_alerts_with_geometry(geometry)
    response = HTTParty.post(
      EXTERNAL_ENDPOINT,
      body: {geometry: geometry}.to_json,
      timeout: 30,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      }
    )

    parse_response(response, "custom geometry")
  end

  def parse_response(response, context)
    if response.success?
      parsed = response.parsed_response
      parsed.is_a?(Array) ? parsed : []
    else
      Rails.logger.error "[AlertFetcher] Failed to fetch #{context}: HTTP #{response.code}"
      []
    end
  rescue => e
    Rails.logger.error "[AlertFetcher] HTTP error for #{context}: #{e.message}"
    []
  end
end

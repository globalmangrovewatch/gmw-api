class UserLocation < ApplicationRecord
  MAX_LOCATIONS_PER_USER = 5

  belongs_to :user
  belongs_to :location, optional: true
  has_one :alert_snapshot, class_name: "LocationAlertSnapshot", dependent: :destroy

  validates :name, presence: true
  validate :location_or_geometry_present
  validate :max_locations_per_user, on: :create

  after_commit :seed_alert_snapshot, on: :create

  scope :system_locations, -> { where.not(location_id: nil) }
  scope :custom_locations, -> { where(location_id: nil) }
  scope :custom_and_test_locations, -> { where(location_id: nil) }
  scope :with_alerts_enabled, -> { where(alerts_enabled: true) }
  scope :alertable, -> {
    with_alerts_enabled
      .joins(:user)
      .where(users: {subscribed_to_location_alerts: true})
  }

  def custom_location?
    custom_geometry.present? && !test_location?
  end

  def system_location?
    location_id.present?
  end

  def test_location?
    test_location_id.present?
  end

  def test_location_id
    bounds&.dig("test_location_id") || bounds&.dig(:test_location_id)
  end

  def geometry_as_geojson
    return nil unless custom_geometry

    RGeo::GeoJSON.encode(custom_geometry)
  end

  def geometry_feature_collection
    return nil unless custom_geometry

    {
      type: "FeatureCollection",
      features: [
        {
          id: "user_location_#{id}",
          type: "Feature",
          properties: {},
          geometry: geometry_as_geojson
        }
      ]
    }
  end

  def custom_geometry=(value)
    if value.blank?
      super(nil)
      return
    end

    geojson = case value
    when String
      value
    when ActionController::Parameters
      value.to_unsafe_h.to_json
    when Hash
      value.to_json
    else
      value.to_json
    end

    parsed_json = JSON.parse(geojson)
    clean_geojson = parsed_json.slice("type", "coordinates").to_json

    factory = RGeo::Cartesian.factory(srid: 4326)
    parsed = RGeo::GeoJSON.decode(clean_geojson, json_parser: :json, geo_factory: factory)
    if parsed.nil?
      feature = {type: "Feature", geometry: parsed_json.slice("type", "coordinates"), properties: {}}.to_json
      parsed = RGeo::GeoJSON.decode(feature, json_parser: :json, geo_factory: factory)
    end
    geometry = parsed.respond_to?(:geometry) ? parsed.geometry : parsed
    super(geometry)
  rescue => e
    Rails.logger.error "RGeo parsing failed (#{e.message}), falling back to PostGIS ST_MakeValid"
    begin
      wkt = self.class.connection.select_value(
        "SELECT ST_AsText(ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON(#{self.class.connection.quote(clean_geojson)}), 4326)))"
      )
      super(factory.parse_wkt(wkt)) if wkt
    rescue => fallback_error
      Rails.logger.error "Failed to parse custom_geometry: #{fallback_error.message}"
      super(nil)
    end
  end

  private

  def location_or_geometry_present
    if location_id.blank? && custom_geometry.blank?
      errors.add(:base, "Either a system location or custom geometry must be provided")
    end
    if location_id.present? && custom_geometry.present?
      errors.add(:base, "Cannot have both system location and custom geometry")
    end
  end

  def max_locations_per_user
    return unless user

    if user.user_locations.count >= MAX_LOCATIONS_PER_USER
      errors.add(:base, "Maximum of #{MAX_LOCATIONS_PER_USER} saved locations allowed")
    end
  end

  def seed_alert_snapshot
    SeedLocationSnapshotJob.perform_later(id)
  rescue Redis::CannotConnectError, Errno::ECONNREFUSED => e
    Rails.logger.warn "[UserLocation] Could not enqueue SeedLocationSnapshotJob (Redis unavailable): #{e.message}. Snapshot will be seeded on next alert sync."
  end
end

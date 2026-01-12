class UserLocation < ApplicationRecord
  MAX_LOCATIONS_PER_USER = 5

  belongs_to :user
  belongs_to :location, optional: true
  has_one :alert_snapshot, class_name: "LocationAlertSnapshot", dependent: :destroy

  validates :name, presence: true
  validate :location_or_geometry_present
  validate :max_locations_per_user, on: :create

  after_create :seed_alert_snapshot

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
    when ActionController::Parameters, Hash
      value.to_unsafe_h.to_json
    else
      value.to_json
    end

    parsed = RGeo::GeoJSON.decode(geojson, json_parser: :json)
    super(parsed)
  rescue => e
    Rails.logger.error "Failed to parse custom_geometry: #{e.message}"
    super(nil)
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
  end
end

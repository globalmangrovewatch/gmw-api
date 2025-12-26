class UserLocation < ApplicationRecord
  MAX_LOCATIONS_PER_USER = 5

  belongs_to :user
  belongs_to :location, optional: true

  validates :name, presence: true
  validate :location_or_geometry_present
  validate :max_locations_per_user, on: :create

  scope :system_locations, -> { where.not(location_id: nil) }
  scope :custom_locations, -> { where(location_id: nil) }

  def custom_geometry=(value)
    if value.is_a?(Hash) || value.is_a?(String)
      geojson = value.is_a?(String) ? value : value.to_json
      parsed = RGeo::GeoJSON.decode(geojson, json_parser: :json)
      super(parsed)
    else
      super
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
end


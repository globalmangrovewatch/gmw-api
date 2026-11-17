class OrganizationsCountry < ApplicationRecord
  belongs_to :organization
  belongs_to :country,
    class_name: "Location",
    foreign_key: :location_id,
    primary_key: :location_id,
    optional: true

  validates :location_id, presence: true
  validate :location_must_be_country

  private

  def location_must_be_country
    return if location_id.blank?
    return if Location.unscoped.exists?(location_id: location_id, location_type: "country")

    errors.add(:location_id, "must be a country")
  end
end

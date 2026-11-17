class Organization < ApplicationRecord
  has_and_belongs_to_many :landscapes
  has_and_belongs_to_many :users
  has_many :organizations_countries, dependent: :destroy, autosave: true, validate: false
  has_many :countries,
    -> { where(location_type: "country").order(:name) },
    through: :organizations_countries,
    source: :country

  validates :organization_name, presence: true
  validate :country_location_ids_must_reference_countries

  def country_location_ids
    organizations_countries.reject(&:marked_for_destruction?).map(&:location_id)
  end

  def country_location_ids=(ids)
    normalized = Array(ids).map { |id| id.to_s.strip }.reject(&:empty?).uniq
    organizations_countries.each(&:mark_for_destruction)
    normalized.each { |location_id| organizations_countries.build(location_id: location_id) }
  end

  def regions
    isos = countries.filter_map { |country| country.iso&.upcase }
    return [] if isos.empty?

    CountryRegion.where(iso3: isos).distinct.order(:region).pluck(:region)
  end

  private

  def country_location_ids_must_reference_countries
    ids = country_location_ids
    if ids.empty?
      errors.add(:country_location_ids, "must include at least one country")
      return
    end

    found = Location.unscoped.where(location_id: ids, location_type: "country").pluck(:location_id)
    return if (ids - found).empty?

    errors.add(:country_location_ids, "must be country locations")
  end
end

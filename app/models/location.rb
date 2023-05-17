class Location < ApplicationRecord
  has_many :mangrove_datum, dependent: :destroy
  has_many :species_locations, dependent: :destroy
  has_many :species, through: :species_locations, source: :specie
  has_many :restoration_potentials, dependent: :destroy
  has_many :habitat_extent, dependent: :destroy
  accepts_nested_attributes_for :species

  # validations
  validates_presence_of :name, :location_type, :iso

  # scopes
  default_scope {
    select(:name, :location_type, :iso, :bounds,
      :location_id, :coast_length_m, :perimeter_m, :area_m2, :id, :created_at)
  }

  def self.worldwide
    find_by(location_type: "worldwide")
  end

  def self.dates_with_data
    unscope(:select).joins(:habitat_extent).select("habitat_extents.year").distinct.order("habitat_extents.year")
  end
end

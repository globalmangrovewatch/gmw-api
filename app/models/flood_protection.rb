class FloodProtection < ApplicationRecord
  belongs_to :location

  UNITS_BY_INDICATOR = {
    area: "km2",
    population: "people",
    stock: "usd"
  }.freeze

  enum :indicator, {area: "area", population: "population", stock: "stock"}, prefix: true
  enum :period, {annual: "annual", "25_year": "25_year", "100_year": "100_year"}, prefix: true
  enum :unit, {km2: "km2", people: "people", usd: "usd"}, prefix: true

  validates_presence_of :indicator, :period, :value, :unit
  validates_uniqueness_of :indicator, scope: [:location_id, :period]

  before_validation :prepare_default_values

  private

  def prepare_default_values
    self.unit ||= UNITS_BY_INDICATOR[indicator&.to_sym]
  end
end

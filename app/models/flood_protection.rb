class FloodProtection < ApplicationRecord
  belongs_to :location

  enum :indicator, {area: "area", population: "population", stock: "stock"}, prefix: true
  enum :period, {annual: "annual", "25_year": "25_year", "100_year": "100_year"}, prefix: true
  enum :unit, {km2: "km2", people: "people", usd: "usd"}, prefix: true

  validates_presence_of :indicator, :period, :value, :unit
end

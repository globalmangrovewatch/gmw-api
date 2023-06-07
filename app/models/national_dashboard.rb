class NationalDashboard < ApplicationRecord
  belongs_to :location

  enum :indicator, {habitat_extent_area: "habitat_extent_area", floods: "floods"}, prefix: true
  enum :unit, {km2: "km2", GDP: "GDP"}, prefix: true

  validates_presence_of :indicator, :year, :value, :unit
end

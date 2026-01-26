class NationalDashboard < ApplicationRecord
  belongs_to :location

  enum :indicator, {habitat_extent_area: "habitat_extent_area", floods: "floods"}, prefix: true
  enum :unit, {km2: "km2", GDP: "GDP"}, prefix: true
  enum :legal_status, {mangrove: "mangrove", forest: "forest"}, prefix: true

  validates_presence_of :indicator, :source, :year, :value, :unit

  def self.legal_status_options
    legal_statuses.keys
  end
end

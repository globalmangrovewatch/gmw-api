class EcosystemService < ApplicationRecord
  belongs_to :location

  enum :indicator, {
    "AGB" => "AGB",
    "SOC" => "SOC",
    "fish" => "fish",
    "shrimp" => "shrimp",
    "crab" => "crab",
    "bivalve" => "bivalve"
  }, default: "SOC", prefix: true

  validates_presence_of :indicator, :value
end

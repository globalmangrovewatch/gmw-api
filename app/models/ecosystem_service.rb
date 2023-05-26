class EcosystemService < ApplicationRecord
  belongs_to :location

  enum :indicator, {
    "AGB" => "AGB",
    "SOC" => "SOC",
    "fish" => "fish",
    "shrimps" => "shrimps",
    "crabs" => "crabs",
    "clams" => "clams"
  }, default: "SOC", prefix: true

  validates_presence_of :indicator, :value
end

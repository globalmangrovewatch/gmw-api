class FisheryMitigationPotential < ApplicationRecord
  belongs_to :location

  enum :indicator, {
    "fish" => "fish",
    "bivalve" => "bivalve",
    "crab" => "crab",
    "shrimp" => "shrimp"
  }

  enum :indicator_type, {
    "absolute" => "absolute",
    "density" => "density"
  }

  validates_presence_of :indicator, :indicator_type, :value
end

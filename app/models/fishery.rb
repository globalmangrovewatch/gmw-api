class Fishery < ApplicationRecord
  belongs_to :location

  enum :category, {
    "0 - 50" => "0 - 50",
    ">50 - 200" => ">50 - 200",
    ">200 - 700" => ">200 - 700",
    ">700 - 2000" => ">700 - 2000",
    ">2000" => ">2000",
    "median" => "median",
    "range_min" => "range_min",
    "range_max" => "range_max"
  }, prefix: true

  validates_presence_of :indicator, :category, :value, :year
end

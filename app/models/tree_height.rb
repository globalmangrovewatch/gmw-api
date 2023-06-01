class TreeHeight < ApplicationRecord
  belongs_to :location
  enum indicator: {"0-5": "0-5", "5-10": "5-10",
                   "10-15": "10-15", "15-20": "15-20",
                   "20-65": "20-65", avg: "avg"}
end

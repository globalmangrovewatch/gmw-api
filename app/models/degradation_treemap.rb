class DegradationTreemap < ApplicationRecord
  belongs_to :location

  enum indicator: {
    degraded_area: "degraded_area",
    lost_area: "lost_area",
    mangrove_area: "mangrove_area",
    restorable_area: "restorable_area"
  }
end

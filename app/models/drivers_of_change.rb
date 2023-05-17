class DriversOfChange < ApplicationRecord
  belongs_to :location

  enum :variable, {
    erosion_pct: "erosion_pct",
    episodic_disturbances_pct: "episodic_disturbances_pct",
    commodities_pct: "commodities_pct",
    npc_pct: "npc_pct",
    settlement_pct: "settlement_pct"
  }, prefix: true
  enum :primary_driver, {
    "NPC" => "NPC",
    "Episodic Disturbances" => "Episodic Disturbances",
    "Erosion" => "Erosion",
    "Settlement" => "Settlement",
    "Commodities" => "Commodities"
  }, prefix: true

  validates_presence_of :variable, :value, :primary_driver
end

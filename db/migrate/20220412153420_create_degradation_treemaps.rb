class CreateDegradationTreemaps < ActiveRecord::Migration[7.0]
  def change
    create_enum :degradation_indicators, ["degraded_area", "lost_area", "main_loss_driver"]
    create_enum :degradation_units, ["ha", "%"]

    create_table :degradation_treemaps do |t|
      t.enum :indicator, enum_type: "degradation_indicators", default: "degraded_area", null: false
      t.float :value
      t.enum :unit, enum_type: "degradation_units", default: "ha", null: false
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end

class ChangeTableDegradationTreemaps < ActiveRecord::Migration[7.0]
  def change
    remove_column :degradation_treemaps, :indicator, :enum, enum_type: "new_degradation_indicators", default: "degraded_area", null: false
    add_column :degradation_treemaps, :indicator, :string, null: false
  end
end

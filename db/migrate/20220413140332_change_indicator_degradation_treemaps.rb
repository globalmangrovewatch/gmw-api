class ChangeIndicatorDegradationTreemaps < ActiveRecord::Migration[7.0]
  def change
    create_enum :degradation_indicators, ["degraded_area", "lost_area", "main_loss_driver"]
    create_enum :new_degradation_indicators, ["degraded_area", "lost_area", "mangrove_area"]

    remove_column :degradation_treemaps, :indicator, :enum, enum_type: 'degradation_indicators', default: 'degraded_area', null: false

    add_column :degradation_treemaps, :indicator, :enum, enum_type: 'new_degradation_indicators', default: 'degraded_area', null: false
    add_column :degradation_treemaps, :main_loss_driver, :text
  end
end

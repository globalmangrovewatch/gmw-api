class AddYearToDegradationTreemaps < ActiveRecord::Migration[7.0]
  def change
    add_column :degradation_treemaps, :year, :integer, default: 2016
  end
end

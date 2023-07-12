class AddSourceLayerToNationalDashboards < ActiveRecord::Migration[7.0]
  def change
    add_column :national_dashboards, :source_layer, :string
  end
end

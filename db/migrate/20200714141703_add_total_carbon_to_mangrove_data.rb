class AddTotalCarbonToMangroveData < ActiveRecord::Migration[5.2]
  def change
    add_column :mangrove_data, :total_carbon, :json
  end
end

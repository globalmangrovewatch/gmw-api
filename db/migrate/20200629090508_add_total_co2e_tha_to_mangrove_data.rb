class AddTotalCo2eThaToMangroveData < ActiveRecord::Migration[5.2]
  def change
    add_column :mangrove_data, :total_co2e_tha, :float
  end
end

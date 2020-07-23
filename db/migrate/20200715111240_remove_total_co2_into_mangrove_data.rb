class RemoveTotalCo2IntoMangroveData < ActiveRecord::Migration[5.2]
  def change
    remove_column :mangrove_data, :total_co2e_tha, :float
  end
end

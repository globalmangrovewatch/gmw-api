class AddNetChangeToMangroveDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :mangrove_data, :net_change_m2, :float
  end
end

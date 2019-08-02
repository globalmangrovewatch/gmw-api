class AddCoastLengthToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :coast_length_m, :float
  end
end

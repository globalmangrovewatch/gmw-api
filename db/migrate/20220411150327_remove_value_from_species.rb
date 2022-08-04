class RemoveValueFromSpecies < ActiveRecord::Migration[7.0]
  def change
    remove_column :species, :value, :float
  end
end

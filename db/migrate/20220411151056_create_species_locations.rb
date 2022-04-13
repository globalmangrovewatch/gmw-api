class CreateSpeciesLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :species_locations do |t|
      t.belongs_to :specie
      t.belongs_to :location
      t.timestamps
    end
  end
end

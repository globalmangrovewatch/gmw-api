class CreateUserLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :user_locations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.string :name, null: false
      t.geometry :custom_geometry, srid: 4326
      t.json :bounds
      t.integer :position

      t.timestamps
    end

    add_index :user_locations, [:user_id, :location_id], unique: true,
              where: "location_id IS NOT NULL", name: "idx_user_locations_system"
    add_index :user_locations, :custom_geometry, using: :gist
  end
end

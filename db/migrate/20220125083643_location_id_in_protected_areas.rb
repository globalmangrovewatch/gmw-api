class LocationIdInProtectedAreas < ActiveRecord::Migration[7.0]
  def change
    drop_table :widget_protected_areas, if_exists: true, force: :cascade

    create_table :widget_protected_areas do |t|
      t.integer :year
      t.float :total_area
      t.float :protected_area
      t.string :location_id

      t.timestamps
    end
    add_index :locations, :location_id, unique: true

    add_foreign_key :widget_protected_areas, :locations,
      column: :location_id, primary_key: :location_id,
      on_delete: :cascade
  end
end

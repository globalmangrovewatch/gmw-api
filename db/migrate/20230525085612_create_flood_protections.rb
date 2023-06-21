class CreateFloodProtections < ActiveRecord::Migration[7.0]
  def change
    create_table :flood_protections do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator, null: false
      t.string :period, null: false
      t.float :value, null: false
      t.string :unit, null: false

      t.timestamps
    end

    add_index :flood_protections, [:location_id, :indicator, :period], unique: true
  end
end

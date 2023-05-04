class CreateTypologies < ActiveRecord::Migration[7.0]
  def change
    create_enum :mangrove_types, ["estuary", "delta", "lagoon", "fringe"]

    create_table :typologies do |t|
      t.integer :value
      t.string :unit, default: "ha"
      t.enum :mangrove_types, enum_type: "mangrove_types", default: "estuary", null: false
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end

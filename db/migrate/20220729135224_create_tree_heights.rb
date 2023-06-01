class CreateTreeHeights < ActiveRecord::Migration[7.0]
  def change
    create_enum :tree_heights_indicators, ["0-5", "5-10", "10-15", "15-20", "20-65", "avg"]
    create_table :tree_heights do |t|
      t.references :location, null: false, foreign_key: true
      t.enum :indicator, enum_type: "tree_heights_indicators", default: "avg", null: false
      t.integer :year
      t.float :value

      t.timestamps
    end
  end
end

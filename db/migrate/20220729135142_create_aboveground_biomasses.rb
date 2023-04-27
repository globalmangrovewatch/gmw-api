class CreateAbovegroundBiomasses < ActiveRecord::Migration[7.0]
  def change
    create_enum :aboveground_biomasses_indicators, ["total", "avg", "0-50", "50-100", "100-150", "150-250", "250-1500"]
    create_table :aboveground_biomasses do |t|
      t.references :location, null: false, foreign_key: true
      t.enum :indicator, enum_type: "aboveground_biomasses_indicators", default: "total", null: false
      t.integer :year
      t.float :value

      t.timestamps
    end
  end
end

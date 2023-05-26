class CreateHabitatExtents < ActiveRecord::Migration[7.0]
  def change
    create_enum :habitat_extent_indicators, ["habitat_extent_area", "linear_coverage"]
    create_table :habitat_extents do |t|
      t.references :location, null: false, foreign_key: true
      t.enum :indicator, enum_type: "habitat_extent_indicators", default: "habitat_extent_area", null: false
      t.integer :year
      t.float :value

      t.timestamps
    end
  end
end

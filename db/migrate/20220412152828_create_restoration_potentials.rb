class CreateRestorationPotentials < ActiveRecord::Migration[7.0]
  def change
    create_enum :restoration_indicators, ["restorable_area", "mangrove_area", "restoration_potential_score"]
    create_enum :restoration_units, ["ha", "%"]

    create_table :restoration_potentials do |t|
      t.enum :indicator, enum_type: 'restoration_indicators', default: 'restorable_area', null: false
      t.float :value
      t.enum :unit, enum_type: 'restoration_units', default: 'ha', null: false
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end

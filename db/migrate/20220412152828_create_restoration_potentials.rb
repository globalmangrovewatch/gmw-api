class CreateRestorationPotentials < ActiveRecord::Migration[7.0]
  def change
    create_enum :indicators, ["restorable_area", "mangrove_area", "restoration_potential_score"]
    create_enum :units, ["ha", "%"]

    create_table :restoration_potentials do |t|
      t.enum, :indicator, enum_type: 'indicators', default: 'restorable_area', null: false
      t.float :value
      t.enum :unit, enum_type: 'units', default: 'ha', null: false
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end

class CreateMitigationPotentials < ActiveRecord::Migration[7.0]
  def change
    create_table :mitigation_potentials do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator
      t.string :category
      t.integer :year
      t.float :value

      t.timestamps
    end
  end
end

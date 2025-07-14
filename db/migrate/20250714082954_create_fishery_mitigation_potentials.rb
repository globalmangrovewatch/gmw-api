class CreateFisheryMitigationPotentials < ActiveRecord::Migration[7.0]
  def change
    create_table :fishery_mitigation_potentials do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator
      t.string :indicator_type
      t.float :value

      t.timestamps
    end
  end
end

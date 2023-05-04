class CreateEcosystemServices < ActiveRecord::Migration[7.0]
  def change
    create_table :ecosystem_services do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator
      t.float :value

      t.timestamps
    end
  end
end

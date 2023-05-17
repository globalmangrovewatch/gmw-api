class CreateDriversOfChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :drivers_of_changes do |t|
      t.references :location, null: false, foreign_key: true
      t.string :variable, null: false
      t.float :value, null: false
      t.string :primary_driver, null: false

      t.timestamps
    end
  end
end

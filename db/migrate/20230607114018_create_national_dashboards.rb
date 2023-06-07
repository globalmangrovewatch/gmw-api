class CreateNationalDashboards < ActiveRecord::Migration[7.0]
  def change
    create_table :national_dashboards do |t|
      t.references :location, null: false, foreign_key: true
      t.string :source
      t.string :indicator, null: false
      t.integer :year, null: false
      t.float :value, null: false
      t.string :layer_link
      t.string :download_link
      t.string :unit, null: false

      t.timestamps
    end
  end
end

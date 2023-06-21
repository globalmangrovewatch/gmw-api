class CreateLocationResources < ActiveRecord::Migration[7.0]
  def change
    create_table :location_resources do |t|
      t.references :location, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :link

      t.timestamps
    end
  end
end

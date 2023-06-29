class CreateFisheries < ActiveRecord::Migration[7.0]
  def change
    create_table :fisheries do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator, null: false
      t.string :category, null: false
      t.float :value, null: false
      t.integer :year, null: false

      t.timestamps
    end
  end
end

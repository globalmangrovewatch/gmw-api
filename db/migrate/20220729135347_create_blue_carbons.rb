class CreateBlueCarbons < ActiveRecord::Migration[7.0]
  def change
    create_table :blue_carbons do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator
      t.integer :year
      t.float :value

      t.timestamps
    end
  end
end

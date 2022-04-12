class CreateBlueCarbonInvestments < ActiveRecord::Migration[7.0]
  def change
    create_table :blue_carbon_investments do |t|
      t.references :location, null: false, foreign_key: true
      t.string :category
      t.float :area
      t.text :description

      t.timestamps
    end
  end
end

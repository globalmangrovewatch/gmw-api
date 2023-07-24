class CreateEcoregions < ActiveRecord::Migration[7.0]
  def change
    create_table :ecoregions do |t|
      t.string :indicator, null: false
      t.float :value, null: false
      t.string :category, null: false

      t.timestamps
    end
  end
end

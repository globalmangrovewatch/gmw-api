class CreateEcoregionReports < ActiveRecord::Migration[7.0]
  def change
    create_table :ecoregion_reports do |t|
      t.string :name, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end

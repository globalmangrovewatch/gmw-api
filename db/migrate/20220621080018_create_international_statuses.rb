class CreateInternationalStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :international_statuses do |t|
      t.references :location, null: false, foreign_key: true
      t.string :indicator
      t.float :value

      t.timestamps
    end
  end
end

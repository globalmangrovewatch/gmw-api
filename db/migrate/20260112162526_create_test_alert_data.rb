class CreateTestAlertData < ActiveRecord::Migration[7.0]
  def change
    create_table :test_alert_data do |t|
      t.string :location_id
      t.json :dates

      t.timestamps
    end
    add_index :test_alert_data, :location_id, unique: true
  end
end

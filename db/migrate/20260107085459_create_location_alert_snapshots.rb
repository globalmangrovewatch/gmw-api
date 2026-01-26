class CreateLocationAlertSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :location_alert_snapshots do |t|
      t.string :location_id
      t.date :latest_date
      t.integer :date_count
      t.json :last_response
      t.datetime :last_checked_at

      t.timestamps
    end
    add_index :location_alert_snapshots, :location_id, unique: true
  end
end

class AddUserLocationIdToLocationAlertSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_reference :location_alert_snapshots, :user_location, foreign_key: true

    change_column_null :location_alert_snapshots, :location_id, true

    remove_index :location_alert_snapshots, :location_id
    add_index :location_alert_snapshots, :location_id, unique: true, where: "location_id IS NOT NULL"
    add_index :location_alert_snapshots, :user_location_id, unique: true, where: "user_location_id IS NOT NULL"
  end
end

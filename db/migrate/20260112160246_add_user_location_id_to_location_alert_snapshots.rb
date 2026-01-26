class AddUserLocationIdToLocationAlertSnapshots < ActiveRecord::Migration[7.0]
  def up
    add_reference :location_alert_snapshots, :user_location, foreign_key: true, index: false

    change_column_null :location_alert_snapshots, :location_id, true

    if index_exists?(:location_alert_snapshots, :location_id)
      remove_index :location_alert_snapshots, :location_id
    end

    add_index :location_alert_snapshots, :location_id,
              unique: true,
              where: "location_id IS NOT NULL",
              name: "idx_location_alert_snapshots_location_id"

    add_index :location_alert_snapshots, :user_location_id,
              unique: true,
              where: "user_location_id IS NOT NULL",
              name: "idx_location_alert_snapshots_user_location_id"
  end

  def down
    remove_index :location_alert_snapshots, name: "idx_location_alert_snapshots_user_location_id", if_exists: true
    remove_index :location_alert_snapshots, name: "idx_location_alert_snapshots_location_id", if_exists: true

    add_index :location_alert_snapshots, :location_id, unique: true

    change_column_null :location_alert_snapshots, :location_id, false

    remove_reference :location_alert_snapshots, :user_location, foreign_key: true
  end
end

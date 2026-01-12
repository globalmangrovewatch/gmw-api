class CreateAlertSyncRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :alert_sync_runs do |t|
      t.string :status, null: false, default: "pending"
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :system_locations_checked, default: 0
      t.integer :custom_locations_checked, default: 0
      t.integer :notifications_sent, default: 0
      t.integer :errors_count, default: 0
      t.text :error_messages
      t.references :triggered_by, foreign_key: {to_table: :admin_users}

      t.timestamps
    end

    add_index :alert_sync_runs, :status
    add_index :alert_sync_runs, :created_at
  end
end

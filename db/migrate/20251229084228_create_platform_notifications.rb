class CreatePlatformNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :platform_notifications do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :notification_type, null: false, default: "platform_update"
      t.datetime :published_at
      t.references :created_by, foreign_key: {to_table: :admin_users}

      t.timestamps
    end

    add_index :platform_notifications, :notification_type
    add_index :platform_notifications, :published_at
  end
end

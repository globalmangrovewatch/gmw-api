class AddNotificationPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :subscribed_to_location_alerts, :boolean, default: false, null: false
    add_column :users, :subscribed_to_newsletter, :boolean, default: false, null: false
    add_column :users, :subscribed_to_platform_updates, :boolean, default: false, null: false
  end
end

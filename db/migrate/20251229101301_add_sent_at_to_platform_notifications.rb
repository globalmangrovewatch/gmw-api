class AddSentAtToPlatformNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :platform_notifications, :sent_at, :datetime
  end
end

class AddAlertsEnabledToUserLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :user_locations, :alerts_enabled, :boolean, default: true, null: false
  end
end

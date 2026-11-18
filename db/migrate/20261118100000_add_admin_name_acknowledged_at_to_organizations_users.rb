class AddAdminNameAcknowledgedAtToOrganizationsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations_users, :admin_name_acknowledged_at, :datetime
  end
end

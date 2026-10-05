class AddRoleToAdminUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :admin_users, :role, :string, null: false, default: "staff"
    execute <<~SQL
      UPDATE admin_users
      SET role = 'super_admin'
    SQL
  end

  def down
    remove_column :admin_users, :role
  end
end

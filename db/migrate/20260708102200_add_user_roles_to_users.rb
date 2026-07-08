class AddUserRolesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_roles, :string, array: true, default: [], null: false
    add_column :users, :user_role_other, :string
  end
end

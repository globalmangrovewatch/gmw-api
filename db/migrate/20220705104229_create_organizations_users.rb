class CreateOrganizationsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations_users do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
    add_index :organizations_users, [:organization_id, :user_id], unique: true
  end
end

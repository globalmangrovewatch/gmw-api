class CreateOrganizationJoinRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_join_requests do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.text :message
      t.references :reviewed_by, foreign_key: {to_table: :users, on_delete: :nullify}
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :organization_join_requests, [:organization_id, :status]
    add_index :organization_join_requests, [:organization_id, :user_id],
      unique: true,
      where: "status = 'pending'",
      name: "index_org_join_requests_one_pending"
  end
end

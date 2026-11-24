class CreateLandscapeOrganizationInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :landscape_organization_invitations do |t|
      t.references :landscape, null: false, foreign_key: true
      t.references :inviting_organization, null: false, foreign_key: {to_table: :organizations}, index: {name: "index_landscape_org_invitations_on_inviting_org"}
      t.references :invited_organization, null: false, foreign_key: {to_table: :organizations}, index: {name: "index_landscape_org_invitations_on_invited_org"}
      t.references :invited_by, null: false, foreign_key: {to_table: :users}
      t.string :status, null: false, default: "pending"
      t.references :responded_by, foreign_key: {to_table: :users, on_delete: :nullify}
      t.datetime :responded_at
      t.datetime :site_data_acknowledged_at
      t.timestamps
    end

    add_index :landscape_organization_invitations, [:invited_organization_id, :status],
      name: "index_landscape_org_invitations_on_invited_org_and_status"
    add_index :landscape_organization_invitations, [:landscape_id, :invited_organization_id],
      unique: true,
      where: "status = 'pending'",
      name: "index_landscape_org_invitations_one_pending"
  end
end

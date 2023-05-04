class CreateLandscapesOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :landscapes_organizations do |t|
      t.references :landscape, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
    add_index :landscapes_organizations, [:landscape_id, :organization_id], unique: true, name: "idx_u_landscapes_organizations"
  end
end

class CreateLandscapesOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :landscapes_organizations do |t|
      t.references :landscape, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end

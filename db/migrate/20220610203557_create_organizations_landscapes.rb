class CreateOrganizationsLandscapes < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations_landscapes do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :landscape, null: false, foreign_key: true

      t.timestamps
    end
  end
end

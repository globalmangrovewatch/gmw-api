class UniqueNamesOnSiteLandscapeOrganization < ActiveRecord::Migration[7.0]
  def change
    add_index :sites, :site_name, unique: true
    add_index :landscapes, :landscape_name, unique: true
    add_index :organizations, :organization_name, unique: true
  end
end

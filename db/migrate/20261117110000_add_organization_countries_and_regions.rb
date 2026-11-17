class AddOrganizationCountriesAndRegions < ActiveRecord::Migration[7.0]
  def up
    create_table :country_regions do |t|
      t.string :iso3, null: false
      t.string :region, null: false
      t.timestamps
    end
    add_index :country_regions, :iso3, unique: true
    add_index :country_regions, :region

    create_table :organizations_countries do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :location_id, null: false
      t.timestamps
    end
    add_index :organizations_countries, [:organization_id, :location_id],
      unique: true,
      name: "index_organizations_countries_on_org_and_location"
    add_index :organizations_countries, :location_id

    CountryRegion.reset_column_information
    CountryRegion.import_reference_data!
  end

  def down
    drop_table :organizations_countries
    drop_table :country_regions
  end
end

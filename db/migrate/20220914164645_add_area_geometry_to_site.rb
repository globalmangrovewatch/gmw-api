class AddAreaGeometryToSite < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :area, :geometry, srid: 4326
    add_index :sites, :area, using: :gist
  end
end

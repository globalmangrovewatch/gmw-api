class AddLandscapeToSites < ActiveRecord::Migration[7.0]
  def change
    add_reference :sites, :landscape, null: false, foreign_key: true
  end
end

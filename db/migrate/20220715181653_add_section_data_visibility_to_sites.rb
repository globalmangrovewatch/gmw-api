class AddSectionDataVisibilityToSites < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :section_data_visibility, :json
  end
end

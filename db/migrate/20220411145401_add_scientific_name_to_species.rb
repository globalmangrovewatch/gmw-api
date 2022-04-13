class AddScientificNameToSpecies < ActiveRecord::Migration[7.0]  
  def change
    add_column :species, :scientific_name, :string
    add_column :species, :common_name, :string
    add_column :species, :iucn_url, :string

    create_enum :red_list_cat, ["ex", "ew", "re", "cr", "en", "vu", "lr", "nt", "lc", "dd"]
    add_column :species, :red_list_cat, :enum, enum_type: 'red_list_cat', default: 'ex', null: false
  end
end

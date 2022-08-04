ActiveAdmin.register Specie do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :scientific_name, :common_name, :iucn_url, :red_list_cat
  #
  # or
  #
  # permit_params do
  #   permitted = [:scientific_name, :common_name, :iucn_url, :red_list_cat]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  active_admin_import({
    before_import: ->(importer) {
      Specie.delete_all
    }
  })

  menu parent: "Widgets"

  permit_params :scientific_name, :common_name, :iucn_url, :red_list_cat, location_ids: []

  index do
    selectable_column
    id_column
    column :scientific_name
    column :common_name
    column :red_list_cat
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :scientific_name, required: true
      f.input :common_name
      f.input :iucn_url, label: 'IUCN URL'
      f.input :red_list_cat, as: :select, 
        collection: ["ex", "ew", "re", "cr", "en", "vu", "lr", "nt", "lc", "dd"], 
        default: 'ex', 
        include_blank: false,
        required: true
    end

    f.inputs 'Locations' do
      f.input :locations, as: :select, input_html: { multiple: true }
    end

    actions
  end
  
end

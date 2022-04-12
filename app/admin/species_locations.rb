ActiveAdmin.register SpeciesLocation do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :specie_id, :location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:specie_id, :location_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import

  permit_params :specie_id, :location_id

  index do
    selectable_column
    id_column
    column 'Specie' do |location_specie|
      link_to location_specie.specie.common_name, admin_species_path(location_specie)
    end
    column :location
    column :updated_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :specie, collection: Specie.all.pluck(:common_name, :id)
      f.input :location
    end

    actions
  end
  
end

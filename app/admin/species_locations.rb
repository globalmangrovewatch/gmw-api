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

  active_admin_import

  permit_params :specie_id, :location_id

  form do |f|
    f.inputs do
      f.input :specie, collection: Specie.all.pluck(:common_name, :id)
      f.input :location
    end

    actions
  end
  
end

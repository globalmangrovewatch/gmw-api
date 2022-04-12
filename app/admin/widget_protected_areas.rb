ActiveAdmin.register WidgetProtectedAreas do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :year, :total_area, :protected_area, :location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:year, :total_area, :protected_area, :location_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu label: 'Proteted areas', parent: 'Widgets'
  
end

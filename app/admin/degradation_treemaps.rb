ActiveAdmin.register DegradationTreemap do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :indicator, :value, :unit, :location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:indicator, :value, :unit, :location_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import

  permit_params :indicator, :value, :unit, :location_id
 
  form do |f|
    f.inputs 'Details' do
      f.input :indicator, as: :select, 
        collection: ["degraded_area", "lost_area", "main_loss_driver"],
        default: 'degraded_area',
        include_blank: false,
        required: true
      f.input :value
      f.input :unit, as: :select, collection: ["ha", "%"], include_blank: false, default: 'ha'
      f.input :year, default: 2016
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end
  
end

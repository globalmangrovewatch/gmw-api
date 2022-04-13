ActiveAdmin.register BlueCarbonInvestment do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :location_id, :category, :area, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:location_id, :category, :area, :description]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import

  permit_params :location_id, :category, :area, :description
 
  form do |f|
    f.inputs 'Details' do
      f.input :category
      f.input :area
      f.input :description
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end
  
end

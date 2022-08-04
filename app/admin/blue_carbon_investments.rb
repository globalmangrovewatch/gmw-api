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

  active_admin_import({
    before_import: ->(importer) {
      BlueCarbonInvestment.delete_all
    }
  })

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

  csv do
    column :category
    column :area
    column :description
    column(:location_id) { |blue_carbon_investments| blue_carbon_investments.location.id }
  end

  controller do
    def csv_filename
      'blue_carbon_investments.csv'
    end
  end
  
end

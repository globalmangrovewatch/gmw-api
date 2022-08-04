ActiveAdmin.register InternationalStatus do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :location_id, :indicator, :value
  #
  # or
  #
  # permit_params do
  #   permitted = [:location_id, :indicator, :value]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      InternationalStatus.delete_all
    }
  })

  permit_params :indicator, :value, :location_id
 
  form do |f|
    f.inputs 'Details' do
      f.input :indicator, as: :select, 
        collection: ["nationally_determined_contributions", "forest_reference_emissions_levels", "ipcc_wetlands_supplement"],
        default: 'nationally_determined_contributions',
        include_blank: false,
        required: true
      f.input :value, as: :string, required: true
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :value
    column(:location_id) { |international_statuses| international_statuses.location.id }
  end

  controller do
    def csv_filename
      'international_status.csv'
    end
  end
  
end

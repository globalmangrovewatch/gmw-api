ActiveAdmin.register Typology do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :value, :unit, :mangrove_types, :location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:value, :unit, :mangrove_types, :location_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      Typology.delete_all
    }
  })

  permit_params :mangrove_types, :value, :unit, :location_id
 
  form do |f|
    f.inputs 'Details' do
      f.input :mangrove_types, as: :select, 
        collection: ["estuary", "delta", "lagoon", "fringe"],
        default: 'estuary',
        include_blank: false,
        required: true
      f.input :value
      f.input :unit, default: 'ha'
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :mangrove_types
    column :value
    column :unit
    column(:location_id) { |typology| typology.location.id }
  end

  controller do
    def csv_filename
      'typology.csv'
    end
  end
  
end

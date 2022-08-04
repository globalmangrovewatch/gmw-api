ActiveAdmin.register RestorationPotential do

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

  active_admin_import({
    before_import: ->(importer) {
      RestorationPotential.delete_all
    }
  })

  permit_params :indicator, :value, :unit, :location_id
 
  form do |f|
    f.inputs 'Details' do
      f.input :indicator, as: :select, 
        collection: ["restorable_area", "mangrove_area", "restoration_potential_score"],
        default: 'restorable_area',
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

  csv do
    column :indicator
    column :value
    column :unit
    column(:location_id) { |restoration_potential| restoration_potential.location.id }
  end

  controller do
    def csv_filename
      'restoration_potentials.csv'
    end
  end

end

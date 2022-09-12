ActiveAdmin.register MitigationPotentials do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :location_id, :indicator, :category, :year, :value
  #
  # or
  #
  # permit_params do
  #   permitted = [:location_id, :indicator, :category, :year, :value]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      MitigationPotentials.delete_all
    }
  })

  permit_params :indicator, :value, :category, :location_id, :year
 
  form do |f|
    f.inputs 'Details' do
      f.input :indicator, as: :select, 
        collection: MitigationPotentials.indicators,
        default: MitigationPotentials.indicators.first,
        include_blank: false,
        required: true
        f.input :category, as: :select, 
        collection: MitigationPotentials.categories,
        default: MitigationPotentials.categories.first,
        include_blank: false,
        required: true
      f.input :value
      f.input :year, default: 2016
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :category
    column :value
    column :year
    column(:location_id) { |mitigation_potentials| mitigation_potentials.location.id }
  end

  controller do
    def csv_filename
      'mitigation_potentials.csv'
    end
  end
  
end

ActiveAdmin.register EcosystemService do

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
    before_batch_import: ->(importer) {
      EcosystemService.delete_all
    }
  })

  permit_params :indicator, :value, :location_id
 
  form do |f|
    f.inputs 'Details' do
      f.input :indicator, as: :select, 
        collection: ["soc", "abgc"],
        default: 'soc',
        include_blank: false,
        required: true
      f.input :value, as: :number, required: true
    end

    f.inputs 'Location' do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :value
    column(:location_id) { |ecosystem_services| ecosystem_services.location.id }
  end

  controller do
    def csv_filename
      'ecosystem_services.csv'
    end
  end
  
end

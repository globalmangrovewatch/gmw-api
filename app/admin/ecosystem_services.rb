ActiveAdmin.register EcosystemService do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      EcosystemService.delete_all
    }
  })

  permit_params :indicator, :value, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :indicator, as: :select, collection: EcosystemService.indicators, include_blank: false
      f.input :value, as: :number, required: true
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :value
    column :location_id
  end

  controller do
    def csv_filename
      "ecosystem_services.csv"
    end
  end
end

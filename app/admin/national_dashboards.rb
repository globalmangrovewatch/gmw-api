ActiveAdmin.register NationalDashboard do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      NationalDashboard.delete_all
    }
  })

  permit_params :source, :indicator, :year, :value, :layer_info, :layer_link, :download_link, :source_layer,
    :unit, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :source
      f.input :indicator, as: :select, collection: NationalDashboard.indicators
      f.input :value
      f.input :unit, as: :select, collection: NationalDashboard.units
      f.input :year
      f.input :layer_info
      f.input :layer_link
      f.input :download_link
      f.input :source_layer
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :location_id
    column :source
    column :source_layer
    column :indicator
    column :value
    column :unit
    column :year
    column :layer_info
    column :layer_link
    column :download_link
  end

  controller do
    def csv_filename
      "national_dashboards.csv"
    end
  end
end

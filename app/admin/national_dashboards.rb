ActiveAdmin.register NationalDashboard do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      NationalDashboard.delete_all
    }
  })

  permit_params :source, :indicator, :year, :value, :layer_link, :download_link, :unit, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :source
      f.input :indicator, as: :select, collection: NationalDashboard.indicators
      f.input :value
      f.input :unit, as: :select, collection: NationalDashboard.units
      f.input :year
      f.input :layer_link
      f.input :download_link
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :source
    column :indicator
    column :value
    column :unit
    column :year
    column :layer_link
    column :download_link
    column :location_id
  end

  controller do
    def csv_filename
      "national_dashboards.csv"
    end
  end
end

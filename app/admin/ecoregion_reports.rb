ActiveAdmin.register EcoregionReport do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      EcoregionReport.delete_all
    }
  })

  permit_params :name, :url

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :url
    end

    actions
  end

  csv do
    column :name
    column :url
  end

  controller do
    def csv_filename
      "ecoregion_reports.csv"
    end
  end
end

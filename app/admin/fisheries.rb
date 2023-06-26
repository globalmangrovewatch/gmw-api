ActiveAdmin.register Fishery do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      Fishery.delete_all
    }
  })

  permit_params :location_id, :value, :category, :indicator, :year

  form do |f|
    f.inputs "Details" do
      f.input :category, as: :select, collection: Fishery.categories
      f.input :indicator
      f.input :year
      f.input :value
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :category
    column :indicator
    column :year
    column :value
    column :location_id
  end

  controller do
    def csv_filename
      "fisheries.csv"
    end
  end
end

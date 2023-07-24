ActiveAdmin.register Ecoregion do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      Ecoregion.delete_all
    }
  })

  permit_params :indicator, :category, :value

  form do |f|
    f.inputs "Details" do
      f.input :indicator, as: :select, collection: Ecoregion.indicators
      f.input :category, as: :select, collection: Ecoregion.categories
      f.input :value
    end

    actions
  end

  csv do
    column :indicator
    column :category
    column :value
  end

  controller do
    def csv_filename
      "ecoregions.csv"
    end
  end
end

ActiveAdmin.register FloodProtection do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      FloodProtection.delete_all
    }
  })

  permit_params :indicator, :period, :value, :unit, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :indicator, as: :select, collection: FloodProtection.indicators
      f.input :period, as: :select, collection: FloodProtection.periods
      f.input :unit, as: :select, collection: FloodProtection.units
      f.input :value
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :period
    column :value
    column :unit
    column :location_id
  end

  controller do
    def csv_filename
      "flood_protections.csv"
    end
  end
end

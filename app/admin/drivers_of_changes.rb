ActiveAdmin.register DriversOfChange do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      DriversOfChange.delete_all
    }
  })

  permit_params :variable, :value, :primary_driver, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :variable, as: :select, collection: DriversOfChange.variables
      f.input :primary_driver, as: :select, collection: DriversOfChange.primary_drivers
      f.input :value
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :variable
    column :primary_driver
    column :value
    column :location_id
  end

  controller do
    def csv_filename
      "drivers_of_changes.csv"
    end
  end
end

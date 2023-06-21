ActiveAdmin.register LocationResource do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      LocationResource.delete_all
    }
  })

  permit_params :name, :description, :link, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :description
      f.input :link
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :name
    column :description
    column :link
    column :location_id
  end

  controller do
    def csv_filename
      "location_resources.csv"
    end
  end
end

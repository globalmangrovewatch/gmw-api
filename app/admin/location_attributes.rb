ActiveAdmin.register LocationAttribute do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      LocationAttribute.delete_all
    }
  })

  permit_params :location_id, :legal_status, :mangrove_breakthrough_committed

  filter :location
  filter :legal_status, as: :select, collection: LocationAttribute.legal_statuses
  filter :mangrove_breakthrough_committed

  index do
    selectable_column
    id_column
    column :location
    column :legal_status
    column :mangrove_breakthrough_committed
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :location, as: :select
      f.input :legal_status, as: :select, collection: LocationAttribute.legal_statuses
      f.input :mangrove_breakthrough_committed
    end

    actions
  end

  csv do
    column :location_id
    column :legal_status
    column :mangrove_breakthrough_committed
  end

  controller do
    def csv_filename
      "location_attributes.csv"
    end
  end
end

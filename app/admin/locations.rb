ActiveAdmin.register Location do
  controller do
    def scoped_collection
      Location.unscoped
    end

    def csv_filename
      "locations.csv"
    end
  end

  active_admin_import({
    before_import: ->(importer) {
      Location.delete_all
    }
  })

  permit_params :name, :location_type, :iso, :bounds, :geometry, :area_m2,
    :perimeter_m, :coast_length_m, :location_id,
    specie_ids: []

  index do
    selectable_column
    id_column
    column :location_id
    column :name
    column :location_type
    column :iso
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.inputs :name
      f.inputs :location_id
      f.inputs :location_type
      f.inputs :iso
      f.inputs :bounds
      f.inputs :geometry
      f.inputs :area_m2
      f.inputs :perimeter_m
      f.inputs :coast_length_m
    end

    f.inputs "Species" do
      f.input :species, collection: Specie.all.pluck(:common_name, :id)
    end

    actions
  end

  csv do
    column :name
    column :location_type
    column :iso
    column :bounds
    column :geometry
    column :area_m2
    column :perimeter_m
    column :coast_length_m
    column :location_id
  end
end

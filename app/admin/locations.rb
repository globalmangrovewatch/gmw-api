ActiveAdmin.register Location do

  active_admin_import

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
    f.inputs 'Details'

    f.inputs 'Species' do
      f.input :species, collection: Specie.all.pluck(:common_name, :id)
    end

    actions
  end

  controller do
    def csv_filename
      'locations.csv'
    end
  end
  
end

ActiveAdmin.register FisheryMitigationPotential do
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      MitigationPotentials.delete_all
    }
  })

  permit_params :indicator, :value, :fishery_type, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :indicator, as: :select,
        collection: FisheryMitigationPotential.indicators,
        default: FisheryMitigationPotential.indicators.first,
        include_blank: false,
        required: true
      f.input :indicator_type, as: :select,
        collection: FisheryMitigationPotential.indicator_types,
        default: FisheryMitigationPotential.indicator_types.first,
        include_blank: false,
        required: true
      f.input :value
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :indicator_type
    column :value
    column(:location_id) { |fishery_mitigation_potential| fishery_mitigation_potential.location.id }
  end

  controller do
    def csv_filename
      "fishery_mitigation_potentials.csv"
    end
  end
end

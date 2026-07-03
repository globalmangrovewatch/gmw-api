STAGING_APP = proc { ENV["APP_ENV"] == "staging" }

ActiveAdmin.register HabitatExtent, as: "habitat_extent" do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :location_id, :indicator, :value
  #
  # or
  #
  # permit_params do
  #   permitted = [:location_id, :indicator, :value]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: "Widgets"

  action_item :delete_all_records, only: :index, if: STAGING_APP do
    link_to "Delete All Records",
      delete_all_records_admin_habitat_extents_path,
      method: :post,
      data: {confirm: "This will permanently delete all habitat extent records. Continue?"}
  end

  collection_action :delete_all_records, method: :post do
    unless STAGING_APP.call
      redirect_to admin_habitat_extents_path, alert: "This action is only available in staging."
      return
    end

    count = HabitatExtent.count
    HabitatExtent.delete_all
    redirect_to admin_habitat_extents_path, notice: "Deleted #{count} habitat extent #{"record".pluralize(count)}."
  end

  IMPORT_COLUMNS = %w[indicator value year location_id gain loss].freeze

  active_admin_import({
    template_object: ActiveAdminImport::Model.new(
      hint: "CSV columns: indicator, value, year, location_id, gain (optional), loss (optional)"
    ),
    before_import: ->(importer) {
      HabitatExtent.delete_all
    },
    before_batch_import: ->(importer) {
      importer.batch_slice_columns(IMPORT_COLUMNS)
    }
  })

  permit_params :indicator, :value, :year, :location_id, :gain, :loss

  index do
    selectable_column
    id_column
    column :indicator
    column :value
    column :gain
    column :loss
    column :year
    column(:location_id) { |habitat_extent| habitat_extent.location.id }
    column :location
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :indicator
      row :value
      row :gain
      row :loss
      row :year
      row(:location_id) { |habitat_extent| habitat_extent.location.id }
      row :location
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :indicator, as: :select,
        collection: ["habitat_extent_area", "linear_coverage"],
        default: "habitat_extent_area",
        include_blank: false,
        required: true
      f.input :value, required: true
      f.input :gain
      f.input :loss
      f.input :year, required: true
    end

    f.inputs "Location" do
      f.input :location, as: :select
    end

    actions
  end

  csv do
    column :indicator
    column :value
    column :gain
    column :loss
    column :year
    column(:location_id) { |habitat_extent| habitat_extent.location.id }
  end

  controller do
    def csv_filename
      "habitat_extent.csv"
    end
  end
end

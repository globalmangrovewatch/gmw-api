ActiveAdmin.register BlueCarbon do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :location_id, :indicator, :year, :value
  #
  # or
  #
  # permit_params do
  #   permitted = [:location_id, :indicator, :year, :value]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu parent: "Widgets"

  active_admin_import({
    before_import: ->(importer) {
      BlueCarbon.delete_all
    }
  })

  permit_params :indicator, :value, :year, :location_id

  form do |f|
    f.inputs "Details" do
      f.input :indicator,
        include_blank: false,
        required: true
      f.input :value, required: true
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
    column :year
    column(:location_id) { |blue_carbons| blue_carbons.location.id }
  end

  controller do
    def csv_filename
      "blue_carbon.csv"
    end
  end
end

ActiveAdmin.register WidgetProtectedAreas do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :year, :total_area, :protected_area, :location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:year, :total_area, :protected_area, :location_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :year, :total_area, :protected_area, :location_id

  menu label: "Proteted areas", parent: "Widgets"

  index do
    selectable_column
    id_column
    column :location
    column :year
    column :total_area
    column :protected_area
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :year, required: true
      f.input :total_area, required: true
      f.input :protected_area, required: true
    end

    f.inputs "Location" do
      f.input :location_id, as: :select, collection: Location.all.pluck(:name, :location_id)
    end

    actions
  end

  csv do
    column :year
    column :total_area
    column :protected_area
    column(:location_id) { |widget_protected_areas| widget_protected_areas.location_id }
  end

  controller do
    def csv_filename
      "protected_areas.csv"
    end
  end
end

ActiveAdmin.register TestAlertData do
  menu priority: 5, label: "Test Alerts"

  permit_params :location_id, :dates

  filter :location_id
  filter :created_at

  action_item :add_test_location_to_user, only: :index do
    link_to "Setup Test for User", setup_test_admin_test_alert_data_index_path
  end

  collection_action :setup_test, method: :get do
    @users = User.where(subscribed_to_location_alerts: true).order(:email)
    render "admin/test_alert_data/setup_test"
  end

  collection_action :create_test_location, method: :post do
    user = User.find(params[:user_id])
    location_id = params[:location_id].presence || "test_location"

    unless location_id.start_with?("test_")
      redirect_to setup_test_admin_test_alert_data_index_path, alert: "Location ID must start with 'test_'"
      return
    end

    TestAlertData.for_location(location_id)

    user_location = user.user_locations.find_or_create_by!(location_id: location_id) do |ul|
      ul.name = "Test Location (#{location_id})"
      ul.alerts_enabled = true
    end

    redirect_to admin_test_alert_data_index_path,
      notice: "Test location '#{location_id}' created and added to #{user.email}. User location ID: #{user_location.id}"
  end

  index do
    selectable_column
    id_column
    column :location_id
    column "Date Count" do |data|
      data.dates&.count || 0
    end
    column "Latest Date" do |data|
      dates = data.dates&.map { |d| d.dig("date", "value") }&.compact&.sort
      dates&.last || "N/A"
    end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :location_id
      row :created_at
      row :updated_at
    end

    panel "Current Dates" do
      if resource.dates.present?
        table_for resource.dates.sort_by { |d| d.dig("date", "value") || "" }.reverse do
          column "Date" do |d|
            d.dig("date", "value")
          end
          column "Count" do |d|
            d["count"]
          end
        end
      else
        para "No dates configured"
      end
    end

    panel "Actions" do
      div do
        link_to "Add Today's Date", add_date_admin_test_alert_datum_path(resource), method: :post, class: "button"
        text_node " "
        link_to "Reset to Default", reset_admin_test_alert_datum_path(resource), method: :post, class: "button"
      end
    end

    snapshot = LocationAlertSnapshot.find_by(location_id: resource.location_id)
    if snapshot
      panel "Stored Snapshot" do
        attributes_table_for snapshot do
          row :id
          row :latest_date
          row :date_count
          row :last_checked_at
        end
      end
    end

    users_with_location = UserLocation.where(location_id: resource.location_id).includes(:user)
    if users_with_location.any?
      panel "Users with this Test Location" do
        table_for users_with_location do
          column :user do |ul|
            link_to ul.user.email, admin_user_path(ul.user)
          end
          column :alerts_enabled do |ul|
            status_tag ul.alerts_enabled ? "Enabled" : "Disabled", class: ul.alerts_enabled ? "green" : "red"
          end
          column :created_at
        end
      end
    end
  end

  form do |f|
    f.inputs "Test Alert Data" do
      f.input :location_id, hint: "Must start with 'test_' (e.g., test_location, test_my_area)"
    end
    f.actions
  end

  member_action :add_date, method: :post do
    date = params[:date] || Date.current.to_s
    count = params[:count]&.to_i || rand(100..500)

    resource.add_date!(date, count)
    redirect_to admin_test_alert_datum_path(resource),
      notice: "Added date #{date} with count #{count}. Run 'Sync Location Alerts' to test notifications."
  end

  member_action :reset, method: :post do
    resource.reset!
    redirect_to admin_test_alert_datum_path(resource), notice: "Reset to default dates."
  end

  controller do
    def create
      location_id = params[:test_alert_data][:location_id]

      unless location_id&.start_with?("test_")
        flash[:error] = "Location ID must start with 'test_'"
        redirect_to new_admin_test_alert_datum_path
        return
      end

      @test_alert_data = TestAlertData.for_location(location_id)
      redirect_to admin_test_alert_datum_path(@test_alert_data), notice: "Test alert data created."
    end
  end
end

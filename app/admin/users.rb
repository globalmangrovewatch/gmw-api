ActiveAdmin.register User do
  menu priority: 2, label: "Users"

  permit_params :email, :password, :password_confirmation, :name, :admin,
    :subscribed_to_location_alerts, :subscribed_to_newsletter, :subscribed_to_platform_updates,
    organization_ids: []

  filter :email
  filter :name
  filter :admin
  filter :subscribed_to_location_alerts
  filter :subscribed_to_newsletter
  filter :subscribed_to_platform_updates
  filter :confirmed_at
  filter :created_at

  scope :all, default: true
  scope :admins
  scope :subscribed_to_alerts
  scope :subscribed_to_newsletter

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :admin
    column :subscribed_to_location_alerts, sortable: true do |user|
      status_tag user.subscribed_to_location_alerts ? "Yes" : "No",
                 class: user.subscribed_to_location_alerts ? "green" : "red"
    end
    column :subscribed_to_newsletter, sortable: true do |user|
      status_tag user.subscribed_to_newsletter ? "Yes" : "No",
                 class: user.subscribed_to_newsletter ? "green" : "red"
    end
    column :subscribed_to_platform_updates, sortable: true do |user|
      status_tag user.subscribed_to_platform_updates ? "Yes" : "No",
                 class: user.subscribed_to_platform_updates ? "green" : "red"
    end
    column :confirmed_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :name
      row :admin do |user|
        status_tag user.admin ? "Yes" : "No", class: user.admin ? "green" : "red"
      end
      row :confirmed_at
      row :created_at
      row :updated_at
    end

    panel "Notification Preferences" do
      attributes_table_for user do
        row :subscribed_to_location_alerts do |u|
          status_tag u.subscribed_to_location_alerts ? "Subscribed" : "Unsubscribed",
                     class: u.subscribed_to_location_alerts ? "green" : "red"
        end
        row :subscribed_to_newsletter do |u|
          status_tag u.subscribed_to_newsletter ? "Subscribed" : "Unsubscribed",
                     class: u.subscribed_to_newsletter ? "green" : "red"
        end
        row :subscribed_to_platform_updates do |u|
          status_tag u.subscribed_to_platform_updates ? "Subscribed" : "Unsubscribed",
                     class: u.subscribed_to_platform_updates ? "green" : "red"
        end
      end
    end

    panel "Organizations" do
      table_for user.organizations do
        column :id
        column :organization_name
      end
    end

    panel "Saved Locations" do
      table_for user.user_locations do
        column :id
        column :name
        column :alerts_enabled do |loc|
          status_tag loc.alerts_enabled ? "Enabled" : "Disabled",
                     class: loc.alerts_enabled ? "green" : "red"
        end
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :password, hint: f.object.new_record? ? "Required" : "Leave blank to keep current password"
      f.input :password_confirmation
      f.input :admin, as: :boolean
    end

    f.inputs "Notification Preferences" do
      f.input :subscribed_to_location_alerts, as: :boolean, label: "Location Alerts"
      f.input :subscribed_to_newsletter, as: :boolean, label: "Newsletter"
      f.input :subscribed_to_platform_updates, as: :boolean, label: "Platform Updates"
    end

    f.inputs "Organizations" do
      f.input :organizations, as: :check_boxes, collection: Organization.all.map { |o| [o.organization_name, o.id] }
    end

    f.actions
  end

  controller do
    def create
      @user = User.new(permitted_params[:user])
      @user.subscribed_to_location_alerts = false
      @user.subscribed_to_newsletter = false
      @user.subscribed_to_platform_updates = false
      @user.skip_confirmation!

      if @user.save
        redirect_to admin_user_path(@user), notice: "User was successfully created."
      else
        render :new
      end
    end

    def update
      @user = User.find(params[:id])
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(permitted_params[:user])
        redirect_to admin_user_path(@user), notice: "User was successfully updated."
      else
        render :edit
      end
    end

    def csv_filename
      "Users.csv"
    end
  end

  csv do
    column :id
    column :email
    column :name
    column :admin
    column :subscribed_to_location_alerts
    column :subscribed_to_newsletter
    column :subscribed_to_platform_updates
    column :confirmed_at
    column :created_at
    column :updated_at
  end

  batch_action :subscribe_to_newsletter do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_newsletter: true)
    end
    redirect_to collection_path, notice: "Users subscribed to newsletter."
  end

  batch_action :unsubscribe_from_newsletter do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_newsletter: false)
    end
    redirect_to collection_path, notice: "Users unsubscribed from newsletter."
  end

  batch_action :subscribe_to_location_alerts do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_location_alerts: true)
    end
    redirect_to collection_path, notice: "Users subscribed to location alerts."
  end

  batch_action :unsubscribe_from_location_alerts do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_location_alerts: false)
    end
    redirect_to collection_path, notice: "Users unsubscribed from location alerts."
  end

  batch_action :subscribe_to_platform_updates do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_platform_updates: true)
    end
    redirect_to collection_path, notice: "Users subscribed to platform updates."
  end

  batch_action :unsubscribe_from_platform_updates do |ids|
    batch_action_collection.find(ids).each do |user|
      user.update(subscribed_to_platform_updates: false)
    end
    redirect_to collection_path, notice: "Users unsubscribed from platform updates."
  end
end


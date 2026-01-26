ActiveAdmin.register PlatformNotification do
  menu priority: 3, label: "Notifications"

  permit_params :title, :content, :notification_type, :published_at

  active_admin_import validate: true,
    template: "admin/platform_notifications/import",
    headers_rewrites: {
      "Title" => "title",
      "Content" => "content",
      "Type" => "notification_type",
      "Published At" => "published_at"
    }

  filter :title
  filter :notification_type, as: :select, collection: PlatformNotification.notification_types
  filter :published_at
  filter :sent_at
  filter :created_at

  scope :all, default: true
  scope :published
  scope :draft
  scope :scheduled
  scope :unsent, -> { where(sent_at: nil).where.not(published_at: nil) }
  scope :newsletters
  scope :platform_updates

  action_item :download_sample, only: :import do
    link_to "Download Sample CSV", download_sample_csv_admin_platform_notifications_path
  end

  collection_action :download_sample_csv, method: :get do
    csv_content = <<~CSV
      title,content,notification_type,published_at
      "Welcome to the Platform!","We are excited to announce new features including improved mapping and data visualization.",platform_update,2024-01-15 10:00:00
      "January Newsletter","Dear subscribers,

      This month's highlights:
      1. New satellite imagery available
      2. Improved carbon calculations
      3. New conservation partnerships

      Thank you for your support!",newsletter,2024-01-20 09:00:00
      "Maintenance Notice (Draft)","The platform will undergo maintenance on February 1st.",platform_update,
    CSV

    send_data csv_content,
              filename: "platform_notifications_sample.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  index do
    selectable_column
    id_column
    column :title
    column :notification_type do |notification|
      status_tag notification.notification_type.humanize,
                 class: notification.notification_type_newsletter? ? "blue" : "orange"
    end
    column :status do |notification|
      case notification.status
      when "published"
        status_tag "Published", class: "green"
      when "scheduled"
        status_tag "Scheduled", class: "orange"
      else
        status_tag "Draft", class: "grey"
      end
    end
    column :sent_at do |notification|
      if notification.sent?
        status_tag "Sent", class: "green"
      elsif notification.published?
        status_tag "Pending", class: "orange"
      else
        status_tag "Not sent", class: "grey"
      end
    end
    column :published_at
    column :created_by do |notification|
      notification.created_by&.email || "N/A"
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :notification_type do |notification|
        status_tag notification.notification_type.humanize,
                   class: notification.notification_type_newsletter? ? "blue" : "orange"
      end
      row :status do |notification|
        case notification.status
        when "published"
          status_tag "Published", class: "green"
        when "scheduled"
          status_tag "Scheduled", class: "orange"
        else
          status_tag "Draft", class: "grey"
        end
      end
      row :published_at
      row :sent_at do |notification|
        if notification.sent?
          "#{notification.sent_at.strftime('%Y-%m-%d %H:%M:%S')} ✓"
        else
          "Not sent yet"
        end
      end
      row :created_by do |notification|
        notification.created_by&.email || "N/A"
      end
      row :created_at
      row :updated_at
    end

    panel "Content" do
      div class: "notification-content" do
        simple_format resource.content
      end
    end

    if resource.published?
      panel "Subscriber Stats" do
        subscriber_count = case resource.notification_type
        when "newsletter"
          User.where(subscribed_to_newsletter: true).count
        when "platform_update"
          User.where(subscribed_to_platform_updates: true).count
        else
          0
        end

        para "This notification will be sent to #{subscriber_count} subscribers."
      end
    end
  end

  form do |f|
    f.inputs "Notification Details" do
      f.input :title
      f.input :notification_type, as: :select, collection: PlatformNotification.notification_types.keys.map { |k| [k.humanize, k] }
      f.input :content, as: :text, input_html: {rows: 15}
    end

    f.inputs "Publishing" do
      f.input :published_at, as: :datepicker,
              hint: "Leave blank to save as draft. Set a future date to schedule. Emails are sent automatically when published."
    end

    f.actions
  end

  controller do
    def create
      @platform_notification = PlatformNotification.new(permitted_params[:platform_notification])
      @platform_notification.created_by = current_admin_user

      if @platform_notification.save
        redirect_to admin_platform_notification_path(@platform_notification), notice: "Notification was successfully created."
      else
        render :new
      end
    end

    def csv_filename
      "PlatformNotifications.csv"
    end
  end

  csv do
    column :id
    column :title
    column :notification_type
    column :content
    column :published_at
    column :sent_at
    column("Created By") { |n| n.created_by&.email }
    column :created_at
    column :updated_at
  end

  batch_action :publish_and_send do |ids|
    batch_action_collection.find(ids).each do |notification|
      notification.update(published_at: Time.current) if notification.draft?
    end
    redirect_to collection_path, notice: "Selected notifications have been published and emails queued."
  end

  batch_action :unpublish, confirm: "This will set unsent notifications back to draft status. Already sent notifications will be skipped. Are you sure?" do |ids|
    unpublished_count = 0
    skipped_count = 0
    batch_action_collection.find(ids).each do |notification|
      if notification.sent?
        skipped_count += 1
      else
        notification.update(published_at: nil, sent_at: nil)
        unpublished_count += 1
      end
    end
    redirect_to collection_path, notice: "#{unpublished_count} notifications unpublished. #{skipped_count} already-sent notifications skipped."
  end

  action_item :publish, only: :show, if: proc { resource.draft? } do
    link_to "Publish & Send", publish_admin_platform_notification_path(resource), method: :put
  end

  action_item :resend, only: :show, if: proc { resource.published? && resource.sent? } do
    link_to "Resend to Subscribers", resend_admin_platform_notification_path(resource), method: :put,
            data: {confirm: "This will send the notification again to all subscribers. Continue?"}
  end

  action_item :unpublish, only: :show, if: proc { resource.scheduled? || (resource.published? && !resource.sent?) } do
    link_to "Unpublish", unpublish_admin_platform_notification_path(resource), method: :put
  end

  member_action :publish, method: :put do
    resource.update(published_at: Time.current)
    redirect_to admin_platform_notification_path(resource), notice: "Notification has been published and emails are being sent."
  end

  member_action :resend, method: :put do
    resource.update_column(:sent_at, nil)
    resource.send_to_subscribers!
    redirect_to admin_platform_notification_path(resource), notice: "Notification is being resent to all subscribers."
  end

  member_action :unpublish, method: :put do
    resource.update(published_at: nil, sent_at: nil)
    redirect_to admin_platform_notification_path(resource), notice: "Notification has been unpublished."
  end
end

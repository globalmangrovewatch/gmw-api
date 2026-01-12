ActiveAdmin.register AlertSyncRun do
  menu priority: 4, label: "Location Alerts"

  actions :index, :show

  filter :status, as: :select, collection: AlertSyncRun.statuses.keys.map { |k| [k.humanize, k] }
  filter :created_at
  filter :triggered_by

  scope :all, default: true
  scope :running, -> { where(status: [:pending, :in_progress]) }
  scope("Completed") { |scope| scope.where(status: :completed) }
  scope("Failed") { |scope| scope.where(status: :failed) }

  action_item :sync_alerts, only: :index do
    if AlertSyncRun.running.any?
      span "Sync in progress...", class: "sync-status-running"
    else
      link_to "Sync Location Alerts", trigger_sync_admin_alert_sync_runs_path, method: :post,
        data: {confirm: "This will check all user locations for new alerts and send notifications. Continue?"}
    end
  end

  collection_action :trigger_sync, method: :post do
    if AlertSyncRun.running.any?
      redirect_to admin_alert_sync_runs_path, alert: "A sync is already in progress."
      return
    end

    sync_run = AlertSyncRun.create!(
      status: :pending,
      triggered_by: current_admin_user
    )

    ProcessAlertSyncJob.perform_later(sync_run.id)

    redirect_to admin_alert_sync_run_path(sync_run),
      notice: "Alert sync started. Refresh this page to see progress."
  end

  index do
    id_column
    column :status do |run|
      case run.status
      when "pending"
        status_tag "Pending", class: "grey"
      when "in_progress"
        status_tag "In Progress", class: "orange"
      when "completed"
        status_tag "Completed", class: "green"
      when "failed"
        status_tag "Failed", class: "red"
      end
    end
    column :triggered_by do |run|
      run.triggered_by&.email || "System"
    end
    column :started_at
    column :completed_at
    column "Duration" do |run|
      run.duration_formatted
    end
    column :system_locations_checked
    column :custom_locations_checked
    column :notifications_sent
    column :errors_count do |run|
      if run.errors_count > 0
        status_tag run.errors_count.to_s, class: "red"
      else
        run.errors_count
      end
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :status do |run|
        case run.status
        when "pending"
          status_tag "Pending", class: "grey"
        when "in_progress"
          status_tag "In Progress", class: "orange"
        when "completed"
          status_tag "Completed", class: "green"
        when "failed"
          status_tag "Failed", class: "red"
        end
      end
      row :triggered_by do |run|
        run.triggered_by&.email || "System"
      end
      row :started_at
      row :completed_at
      row "Duration" do |run|
        run.duration_formatted
      end
      row :created_at
    end

    panel "Statistics" do
      attributes_table_for resource do
        row :system_locations_checked
        row :custom_locations_checked
        row :notifications_sent
        row :errors_count
      end
    end

    if resource.error_messages.present?
      panel "Errors" do
        pre resource.error_messages, style: "white-space: pre-wrap; font-family: monospace; background: #fff3cd; padding: 15px; border-radius: 4px;"
      end
    end

    if resource.running?
      panel "Status" do
        para "This sync is still running. Refresh the page to see updated progress.", style: "color: #856404; font-weight: bold;"
      end
    end
  end

  controller do
    def scoped_collection
      super.order(created_at: :desc)
    end
  end

  csv do
    column :id
    column :status
    column("Triggered By") { |r| r.triggered_by&.email }
    column :started_at
    column :completed_at
    column :system_locations_checked
    column :custom_locations_checked
    column :notifications_sent
    column :errors_count
    column :created_at
  end
end

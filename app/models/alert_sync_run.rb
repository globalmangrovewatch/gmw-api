class AlertSyncRun < ApplicationRecord
  belongs_to :triggered_by, class_name: "AdminUser", optional: true

  enum :status, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    failed: "failed"
  }, prefix: true

  scope :recent, -> { order(created_at: :desc) }
  scope :running, -> { where(status: [:pending, :in_progress]) }

  def start!
    update!(status: :in_progress, started_at: Time.current)
  end

  def complete!(stats = {})
    update!(
      status: :completed,
      completed_at: Time.current,
      **stats
    )
  end

  def fail!(message)
    current_errors = error_messages.present? ? "#{error_messages}\n#{message}" : message
    update!(
      status: :failed,
      completed_at: Time.current,
      error_messages: current_errors,
      errors_count: (errors_count || 0) + 1
    )
  end

  def increment_stat!(stat_name, amount = 1)
    increment!(stat_name, amount)
  end

  def add_error!(message)
    current_errors = error_messages.present? ? "#{error_messages}\n#{message}" : message
    update!(
      error_messages: current_errors,
      errors_count: (errors_count || 0) + 1
    )
  end

  def running?
    status_pending? || status_in_progress?
  end

  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    end_time - started_at
  end

  def duration_formatted
    return "N/A" unless duration

    if duration < 60
      "#{duration.round(1)}s"
    elsif duration < 3600
      "#{(duration / 60).round(1)}m"
    else
      "#{(duration / 3600).round(1)}h"
    end
  end
end

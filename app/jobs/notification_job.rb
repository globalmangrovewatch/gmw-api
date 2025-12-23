class NotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(recipients:, subject:, body:, html_body: nil)
    NotificationService.send_notification(
      recipients: recipients,
      subject: subject,
      body: body,
      html_body: html_body,
      deliver_later: false
    )
  end
end


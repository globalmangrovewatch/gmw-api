class NotificationMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@globalmangrovewatch.org")

  def notification_email(recipients:, subject:, body:, html_body: nil)
    @body = body
    @html_body = html_body

    mail(
      to: recipients,
      subject: subject
    ) do |format|
      if html_body.present?
        format.html { render "notification_email_html" }
      end
      format.text { render "notification_email_text" }
    end
  end

  def custom_template_email(recipients:, subject:, template:, template_data: {})
    @template_data = template_data

    mail(
      to: recipients,
      subject: subject,
      template_name: template
    )
  end

  def platform_notification_email(user:, notification:)
    @user = user
    @notification = notification
    @unsubscribe_type = notification.notification_type

    subject = case notification.notification_type
    when "newsletter"
      "[GMW Newsletter] #{notification.title}"
    when "platform_update"
      "[GMW Update] #{notification.title}"
    else
      notification.title
    end

    mail(
      to: user.email,
      subject: subject
    )
  end

  def organization_join_request_received(recipient_email:, organization_name:, requester_name:, message:)
    @organization_name = organization_name
    @requester_name = requester_name.presence || "A platform user"
    @message = message.presence

    mail(
      to: recipient_email,
      subject: "New request to join #{organization_name}"
    )
  end

  def organization_join_request_decided(recipient_email:, organization_name:, status:)
    @organization_name = organization_name
    @status = status

    mail(
      to: recipient_email,
      subject: "Your request to join #{organization_name} was #{status}"
    )
  end

  def location_alert_email(user:, location_name:, new_dates:)
    @user = user
    @location_name = location_name
    @new_dates = new_dates
    @latest_date = new_dates.last

    mail(
      to: user.email,
      subject: "[GMW Alert] New data available for #{location_name}"
    )
  end
end

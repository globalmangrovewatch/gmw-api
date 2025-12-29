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
end

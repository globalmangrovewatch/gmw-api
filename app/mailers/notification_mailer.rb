class NotificationMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@gmw-api.com")

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
end


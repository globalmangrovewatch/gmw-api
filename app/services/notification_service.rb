class NotificationService
  class << self
    def send_notification(recipients:, subject:, body:, html_body: nil, deliver_later: false)
      validate_recipients!(recipients)
      validate_content!(subject, body)

      mailer = NotificationMailer.notification_email(
        recipients: Array(recipients),
        subject: subject,
        body: body,
        html_body: html_body
      )

      deliver_later ? mailer.deliver_later : mailer.deliver_now
    end

    def send_custom_template(recipients:, subject:, template:, template_data: {}, deliver_later: false)
      validate_recipients!(recipients)
      validate_content!(subject, template)

      mailer = NotificationMailer.custom_template_email(
        recipients: Array(recipients),
        subject: subject,
        template: template,
        template_data: template_data
      )

      deliver_later ? mailer.deliver_later : mailer.deliver_now
    end

    def send_bulk_notifications(notifications:, deliver_later: true)
      results = []

      notifications.each do |notification|
        begin
          result = send_notification(
            recipients: notification[:recipients],
            subject: notification[:subject],
            body: notification[:body],
            html_body: notification[:html_body],
            deliver_later: deliver_later
          )
          results << {success: true, recipients: notification[:recipients]}
        rescue => e
          results << {success: false, recipients: notification[:recipients], error: e.message}
        end
      end

      results
    end

    private

    def validate_recipients!(recipients)
      recipients_array = Array(recipients)
      raise ArgumentError, "Recipients cannot be empty" if recipients_array.empty?

      recipients_array.each do |email|
        raise ArgumentError, "Invalid email format: #{email}" unless valid_email?(email)
      end
    end

    def validate_content!(subject, body_or_template)
      raise ArgumentError, "Subject cannot be blank" if subject.blank?
      raise ArgumentError, "Body/Template cannot be blank" if body_or_template.blank?
    end

    def valid_email?(email)
      email.to_s.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    end
  end
end


require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "#notification_email" do
    let(:recipients) { ["user1@example.com", "user2@example.com"] }
    let(:subject) { "Test Notification" }
    let(:body) { "This is a test notification body" }
    let(:html_body) { "<p>This is a <strong>test</strong> notification body</p>" }

    context "with text body only" do
      let(:mail) do
        described_class.notification_email(
          recipients: recipients,
          subject: subject,
          body: body
        )
      end

      it "sends to the correct recipients" do
        expect(mail.to).to eq(recipients)
      end

      it "has the correct subject" do
        expect(mail.subject).to eq(subject)
      end

      it "includes the body in the text part" do
        expect(mail.body.to_s).to include(body)
      end

      it "renders as plain text" do
        expect(mail.content_type).to include("text/plain")
      end
    end

    context "with HTML body" do
      let(:mail) do
        described_class.notification_email(
          recipients: recipients,
          subject: subject,
          body: body,
          html_body: html_body
        )
      end

      it "sends to the correct recipients" do
        expect(mail.to).to eq(recipients)
      end

      it "has the correct subject" do
        expect(mail.subject).to eq(subject)
      end

      it "includes the text body in the text part" do
        expect(mail.text_part.body.to_s).to include(body)
      end

      it "includes the HTML body in the HTML part" do
        expect(mail.html_part.body.to_s).to include(html_body)
      end

      it "has multipart content" do
        expect(mail.parts.size).to eq(2)
      end
    end
  end

  describe "#custom_template_email" do
    let(:recipients) { ["user@example.com"] }
    let(:subject) { "Custom Template" }
    let(:template) { "notification_email_text" }
    let(:template_data) { {name: "John", code: "ABC123"} }

    it "sends to the correct recipients" do
      mail = described_class.custom_template_email(
        recipients: recipients,
        subject: subject,
        template: template,
        template_data: template_data
      )

      expect(mail.to).to eq(recipients)
    end

    it "has the correct subject" do
      mail = described_class.custom_template_email(
        recipients: recipients,
        subject: subject,
        template: template,
        template_data: template_data
      )

      expect(mail.subject).to eq(subject)
    end
  end
end


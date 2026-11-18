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

  describe "organization join requests" do
    let(:organization_name) { "Mangrove Partnership" }
    let(:requester_name) { "Ana Requester" }
    let(:requester_email) { "ana.requester@wetlands.org" }
    let(:admin_email) { "ada.admin@wetlands.org" }
    let(:other_admin_email) { "bao.admin@wetlands.org" }

    def rendered_content(mail)
      [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    end

    it "tells one admin about a request without any contact details" do
      mail = described_class.organization_join_request_received(
        recipient_email: admin_email,
        organization_name: organization_name,
        requester_name: requester_name,
        message: "I work on restoration"
      )

      expect(mail.to).to eq([admin_email])
      content = rendered_content(mail)
      expect(content).to include(organization_name)
      expect(content).to include(requester_name)
      expect(content).to include("I work on restoration")
      expect(content).not_to include(requester_email)
      expect(content).not_to include(admin_email)
      expect(content).not_to include(other_admin_email)
    end

    it "uses a name that is not an email address when the requester name is blank" do
      mail = described_class.organization_join_request_received(
        recipient_email: admin_email,
        organization_name: organization_name,
        requester_name: nil,
        message: nil
      )

      content = rendered_content(mail)
      expect(content).to include("A platform user")
      expect(content).not_to include("@")
    end

    it "tells the requester the decision without admin contact details" do
      mail = described_class.organization_join_request_decided(
        recipient_email: requester_email,
        organization_name: organization_name,
        status: "approved"
      )

      expect(mail.to).to eq([requester_email])
      content = rendered_content(mail)
      expect(content).to include("Your request to join #{organization_name} was approved")
      expect(content).not_to include(admin_email)
      expect(content).not_to include(other_admin_email)
      expect(content).not_to include(requester_email)
    end
  end
end

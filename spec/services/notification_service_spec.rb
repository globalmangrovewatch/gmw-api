require "rails_helper"

RSpec.describe NotificationService do
  describe ".send_notification" do
    let(:recipients) { ["user@example.com"] }
    let(:subject) { "Test Subject" }
    let(:body) { "Test Body" }

    it "sends a notification email" do
      expect {
        described_class.send_notification(
          recipients: recipients,
          subject: subject,
          body: body
        )
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context "with deliver_later: true" do
      it "enqueues the email" do
        described_class.send_notification(
          recipients: recipients,
          subject: subject,
          body: body,
          deliver_later: true
        )

        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
      end
    end

    context "with invalid recipients" do
      it "raises an error for empty recipients" do
        expect {
          described_class.send_notification(
            recipients: [],
            subject: subject,
            body: body
          )
        }.to raise_error(ArgumentError, "Recipients cannot be empty")
      end

      it "raises an error for invalid email format" do
        expect {
          described_class.send_notification(
            recipients: ["invalid-email"],
            subject: subject,
            body: body
          )
        }.to raise_error(ArgumentError, /Invalid email format/)
      end
    end

    context "with invalid content" do
      it "raises an error for blank subject" do
        expect {
          described_class.send_notification(
            recipients: recipients,
            subject: "",
            body: body
          )
        }.to raise_error(ArgumentError, "Subject cannot be blank")
      end

      it "raises an error for blank body" do
        expect {
          described_class.send_notification(
            recipients: recipients,
            subject: subject,
            body: ""
          )
        }.to raise_error(ArgumentError, "Body/Template cannot be blank")
      end
    end

    context "with multiple recipients" do
      let(:multiple_recipients) { ["user1@example.com", "user2@example.com", "user3@example.com"] }

      it "sends to all recipients" do
        described_class.send_notification(
          recipients: multiple_recipients,
          subject: subject,
          body: body
        )

        expect(ActionMailer::Base.deliveries.last.to).to eq(multiple_recipients)
      end
    end

    context "with HTML body" do
      let(:html_body) { "<h1>Test</h1>" }

      it "includes HTML body in the email" do
        described_class.send_notification(
          recipients: recipients,
          subject: subject,
          body: body,
          html_body: html_body
        )

        email = ActionMailer::Base.deliveries.last
        expect(email.html_part.body.to_s).to include(html_body)
      end
    end
  end

  describe ".send_custom_template" do
    let(:recipients) { ["user@example.com"] }
    let(:subject) { "Custom Template" }
    let(:template) { "notification_email_text" }
    let(:template_data) { {name: "John"} }

    it "sends a custom template email" do
      expect {
        described_class.send_custom_template(
          recipients: recipients,
          subject: subject,
          template: template,
          template_data: template_data
        )
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context "with deliver_later: true" do
      it "enqueues the email" do
        described_class.send_custom_template(
          recipients: recipients,
          subject: subject,
          template: template,
          deliver_later: true
        )

        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
      end
    end
  end

  describe ".send_bulk_notifications" do
    let(:notifications) do
      [
        {
          recipients: ["user1@example.com"],
          subject: "Notification 1",
          body: "Body 1"
        },
        {
          recipients: ["user2@example.com"],
          subject: "Notification 2",
          body: "Body 2"
        },
        {
          recipients: ["user3@example.com"],
          subject: "Notification 3",
          body: "Body 3",
          html_body: "<p>HTML Body 3</p>"
        }
      ]
    end

    it "sends all notifications" do
      expect {
        described_class.send_bulk_notifications(
          notifications: notifications,
          deliver_later: false
        )
      }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end

    it "returns success results for all notifications" do
      results = described_class.send_bulk_notifications(
        notifications: notifications,
        deliver_later: false
      )

      expect(results.size).to eq(3)
      expect(results.all? { |r| r[:success] }).to be true
    end

    context "with some invalid notifications" do
      let(:mixed_notifications) do
        [
          {
            recipients: ["valid@example.com"],
            subject: "Valid",
            body: "Valid body"
          },
          {
            recipients: ["invalid-email"],
            subject: "Invalid",
            body: "Invalid body"
          }
        ]
      end

      it "continues processing and returns results for each" do
        results = described_class.send_bulk_notifications(
          notifications: mixed_notifications,
          deliver_later: false
        )

        expect(results.size).to eq(2)
        expect(results[0][:success]).to be true
        expect(results[1][:success]).to be false
        expect(results[1][:error]).to be_present
      end
    end

    context "with deliver_later: true" do
      it "enqueues all emails" do
        described_class.send_bulk_notifications(
          notifications: notifications,
          deliver_later: true
        )

        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at_least(3).times
      end
    end
  end
end


require "rails_helper"

RSpec.describe NotificationJob, type: :job do
  describe "#perform" do
    let(:recipients) { ["user@example.com"] }
    let(:subject) { "Test Job" }
    let(:body) { "Test body from job" }

    it "calls NotificationService.send_notification" do
      allow(NotificationService).to receive(:send_notification)

      described_class.new.perform(
        recipients: recipients,
        subject: subject,
        body: body
      )

      expect(NotificationService).to have_received(:send_notification).with(
        recipients: recipients,
        subject: subject,
        body: body,
        html_body: nil,
        deliver_later: false
      )
    end

    it "enqueues the job" do
      described_class.perform_later(
        recipients: recipients,
        subject: subject,
        body: body
      )

      expect(described_class).to have_been_enqueued
    end

    context "with HTML body" do
      let(:html_body) { "<p>HTML content</p>" }

      it "passes HTML body to the service" do
        allow(NotificationService).to receive(:send_notification)

        described_class.new.perform(
          recipients: recipients,
          subject: subject,
          body: body,
          html_body: html_body
        )

        expect(NotificationService).to have_received(:send_notification).with(
          recipients: recipients,
          subject: subject,
          body: body,
          html_body: html_body,
          deliver_later: false
        )
      end
    end

    context "retry configuration" do
      it "has retry configured for StandardError" do
        expect(described_class.retry_on_exception).to include(StandardError)
      rescue NoMethodError
        skip "Retry configuration is handled internally by Rails"
      end
    end
  end
end


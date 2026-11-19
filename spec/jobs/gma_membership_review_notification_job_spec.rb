require "rails_helper"

RSpec.describe GmaMembershipReviewNotificationJob, type: :job do
  it "emails the org admin the decision without contact details" do
    reviewer = create(:user, email: "validator.job@gma.org", name: "Val Reviewer")
    organization = create(:organization, organization_name: "Pending Chapter", gma_membership: "member")
    organization.review_gma_membership!("verify", reviewer: reviewer, reason: "Membership confirmed")
    admin = create(:user, email: "ada.admin@wetlands.org", name: "Ada Admin")

    described_class.new.perform(organization.id, admin.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([admin.email])
    content = [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    expect(content).to include("Pending Chapter")
    expect(content).to include("was verified")
    expect(content).to include("Membership confirmed")
    expect(content).not_to include(reviewer.email)
    expect(content).not_to include(reviewer.name)
    expect(content).not_to include(admin.email)
  end

  it "does nothing when the claim is no longer decided" do
    organization = create(:organization, gma_membership: "member")
    admin = create(:user)

    described_class.new.perform(organization.id, admin.id)

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end

require "rails_helper"

RSpec.describe LandscapeOrganizationInvitationNotificationJob, type: :job do
  it "sends one invitation email to the given admin" do
    invitation = create(
      :landscape_organization_invitation,
      invited_by: create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
    )
    invitation.landscape.update!(landscape_name: "Sundarbans")
    invitation.inviting_organization.update!(organization_name: "Mangrove Partnership")
    invitation.invited_organization.update!(organization_name: "Coastal Alliance")
    admin = create(:user, email: "bao.admin@wetlands.org")

    described_class.new.perform(invitation.id, "created", admin.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([admin.email])
    content = [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    expect(content).to include("Ada Admin")
    expect(content).to include("Sundarbans")
    expect(content).to include("Mangrove Partnership")
    expect(content).to include("Coastal Alliance")
    expect(content).to include(LandscapeOrganizationInvitation::SITE_DATA_NOTICE)
    expect(content).not_to include("ada.admin@wetlands.org")
    expect(content).not_to include("bao.admin@wetlands.org")
  end

  it "sends the decision without the acknowledgement notice when it was declined" do
    invitation = create(:landscape_organization_invitation, status: "declined")
    invitation.landscape.update!(landscape_name: "Sundarbans")
    invitation.invited_organization.update!(organization_name: "Coastal Alliance")
    inviter = invitation.invited_by

    described_class.new.perform(invitation.id, "decided", inviter.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([inviter.email])
    content = [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    expect(content).to include("was declined")
    expect(content).to include("Coastal Alliance")
    expect(content).to include("Sundarbans")
    expect(content).not_to include("can now see")
    expect(content).not_to include(inviter.email)
  end
end

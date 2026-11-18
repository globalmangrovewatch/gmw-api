require "rails_helper"

RSpec.describe OrganizationJoinRequestNotificationJob, type: :job do
  it "sends one new-request email to the given admin" do
    request = create(:organization_join_request, user: create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org"), message: "I work on restoration")
    admin = create(:user, email: "ada.admin@wetlands.org")

    described_class.new.perform(request.id, "created", admin.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([admin.email])
    content = [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    expect(content).to include("Ana Requester")
    expect(content).to include("I work on restoration")
    expect(content).not_to include("ana.requester@wetlands.org")
    expect(content).not_to include("ada.admin@wetlands.org")
  end

  it "sends the decision to the requester" do
    requester = create(:user, email: "ana.requester@wetlands.org")
    request = create(:organization_join_request, user: requester, status: "approved")
    admin = create(:user, email: "ada.admin@wetlands.org")
    request.update!(reviewed_by: admin, reviewed_at: Time.current)

    described_class.new.perform(request.id, "decided", requester.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([requester.email])
    content = [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
    expect(content).to include("was approved")
    expect(content).not_to include(admin.email)
    expect(content).not_to include(requester.email)
  end
end

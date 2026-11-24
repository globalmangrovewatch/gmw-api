require "rails_helper"

RSpec.describe "Landscape organization invitations", type: :request do
  include ActiveJob::TestHelper

  describe "POST /api/v2/landscapes/:id/invitations" do
    it "requires a signed-in user" do
      landscape = create(:landscape)
      inviting = create(:organization)
      invited = create(:organization)

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(LandscapeOrganizationInvitation.count).to eq(0)
    end

    it "creates one pending invitation and emails each admin of the invited organization" do
      landscape = create(:landscape, landscape_name: "Sundarbans")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      invited = create(:organization, organization_name: "Coastal Alliance")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      other_admin = add_admin(invited, "cao.admin@wetlands.org", "Cao Admin")

      expect {
        post "/api/v2/landscapes/#{landscape.id}/invitations",
          params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
          headers: auth_headers(inviter),
          as: :json
      }.to have_enqueued_job(LandscapeOrganizationInvitationNotificationJob).exactly(2).times

      expect(response).to have_http_status(:created)
      expect(response_json).to include(
        "landscape_id" => landscape.id,
        "landscape_name" => "Sundarbans",
        "inviting_organization_id" => inviting.id,
        "inviting_organization_name" => "Mangrove Partnership",
        "invited_organization_id" => invited.id,
        "invited_organization_name" => "Coastal Alliance",
        "status" => "pending",
        "inviter_name" => "Ada Admin",
        "site_data_notice" => LandscapeOrganizationInvitation::SITE_DATA_NOTICE,
        "site_data_acknowledged_at" => nil,
        "responded_at" => nil
      )
      expect_no_emails(inviter.email, admin.email, other_admin.email)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly([admin.email], [other_admin.email])
      ActionMailer::Base.deliveries.each do |mail|
        content = mail_content(mail)
        expect(content).to include("Ada Admin")
        expect(content).to include("Sundarbans")
        expect(content).to include("Mangrove Partnership")
        expect(content).to include("Coastal Alliance")
        expect(content).to include(LandscapeOrganizationInvitation::SITE_DATA_NOTICE)
        expect(content).not_to include(inviter.email)
        expect(content).not_to include(admin.email)
        expect(content).not_to include(other_admin.email)
      end
    end

    it "rejects a second pending invitation and an organization already on the landscape" do
      landscape = create(:landscape, landscape_name: "Sundarbans")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      invited = create(:organization, organization_name: "Coastal Alliance")
      already_linked = create(:organization, organization_name: "Already Linked")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      LandscapesOrganizations.create!(landscape: landscape, organization: already_linked)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(inviter),
        as: :json
      expect(response).to have_http_status(:created)

      expect {
        post "/api/v2/landscapes/#{landscape.id}/invitations",
          params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
          headers: auth_headers(inviter),
          as: :json
      }.not_to change(LandscapeOrganizationInvitation, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["invited_organization"]).to include("already has a pending invitation")

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: already_linked.id},
        headers: auth_headers(inviter),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["invited_organization"]).to include("is already part of this landscape")
    end

    it "tells an admin to link an organization they belong to directly" do
      landscape = create(:landscape)
      inviting = create(:organization)
      invited = create(:organization)
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      OrganizationsUsers.create!(organization: invited, user: inviter, role: "org-user")

      expect {
        post "/api/v2/landscapes/#{landscape.id}/invitations",
          params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
          headers: auth_headers(inviter),
          as: :json
      }.not_to change(LandscapeOrganizationInvitation, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["invited_organization"]).to include("can be linked directly")
    end

    it "does not put an email-shaped inviter name in the response" do
      landscape = create(:landscape, landscape_name: "Sundarbans")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      invited = create(:organization, organization_name: "Coastal Alliance")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "ada.admin@wetlands.org")
      add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(inviter),
        as: :json

      expect(response).to have_http_status(:created)
      expect(response_json["inviter_name"]).to be_nil
      expect(response.body).not_to include("ada.admin@wetlands.org")
      expect(response.body).not_to include("bao.admin@wetlands.org")
    end
  end

  describe "GET /api/v2/organizations/:id/landscape_invitations" do
    it "lists pending invitations for an acknowledged admin of the invited organization" do
      invited = create(:organization, organization_name: "Coastal Alliance")
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      older = create(
        :landscape_organization_invitation,
        invited_organization: invited,
        invited_by: create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
      )
      older.landscape.update!(landscape_name: "Sundarbans")
      newer_landscape = create(:landscape, landscape_name: "Later Landscape")
      newer = create(
        :landscape_organization_invitation,
        landscape: newer_landscape,
        invited_organization: invited,
        invited_by: create(:user, name: "Dana Admin", email: "dana.admin@wetlands.org")
      )
      declined = create(:landscape_organization_invitation, invited_organization: invited, status: "declined")
      declined.landscape.update!(landscape_name: "Secret Declined Landscape")

      get "/api/v2/organizations/#{invited.id}/landscape_invitations", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(response_json.map { |invitation| invitation["id"] }).to eq([older.id, newer.id])
      expect(response_json.first).to include(
        "status" => "pending",
        "landscape_name" => "Sundarbans",
        "inviter_name" => "Ada Admin",
        "site_data_notice" => LandscapeOrganizationInvitation::SITE_DATA_NOTICE,
        "site_data_acknowledged_at" => nil
      )
      expect(response.body).not_to include("Secret Declined Landscape")
      expect_no_emails("ada.admin@wetlands.org", "bao.admin@wetlands.org", "dana.admin@wetlands.org")
    end
  end

  describe "PATCH /api/v2/organizations/:id/landscape_invitations/:invitation_id" do
    it "accepts with an acknowledgement, links the organization, and lets its members see the sites" do
      landscape = create(:landscape, landscape_name: "Sundarbans")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      invited = create(:organization, organization_name: "Coastal Alliance")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      other_admin = add_admin(invited, "cao.admin@wetlands.org", "Cao Admin")
      member = add_member(invited, "member.one@wetlands.org")
      other_member = add_member(invited, "member.two@wetlands.org")
      site = create(:site, landscape: landscape, site_name: "Hidden plot")

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(inviter),
        as: :json
      invitation_id = response_json["id"]
      clear_enqueued_jobs

      [member, other_member].each do |user|
        get "/api/v2/sites/#{site.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:forbidden)

        get "/api/v2/landscapes/#{landscape.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:forbidden)
      end

      expect {
        patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation_id}",
          params: {status: "accepted", site_data_acknowledged: true},
          headers: auth_headers(admin),
          as: :json
      }.to have_enqueued_job(LandscapeOrganizationInvitationNotificationJob).exactly(3).times

      expect(response).to have_http_status(:ok)
      expect(response_json).to include(
        "id" => invitation_id,
        "status" => "accepted",
        "site_data_notice" => LandscapeOrganizationInvitation::SITE_DATA_NOTICE
      )
      expect(response_json["site_data_acknowledged_at"]).to be_present
      expect(response_json["responded_at"]).to be_present
      expect(LandscapesOrganizations.exists?(landscape: landscape, organization: invited)).to be(true)
      expect_no_emails(inviter.email, admin.email, other_admin.email, member.email)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly(
        [admin.email],
        [other_admin.email],
        [inviter.email]
      )
      ActionMailer::Base.deliveries.each do |mail|
        content = mail_content(mail)
        expect(content).to include("was accepted")
        expect(content).to include("can now see this landscape's site data")
        expect(content).to include("Sundarbans")
        expect(content).to include("Coastal Alliance")
        expect(content).not_to include(inviter.email)
        expect(content).not_to include(admin.email)
        expect(content).not_to include(other_admin.email)
      end

      [member, other_member].each do |user|
        get "/api/v2/sites/#{site.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:ok)
        expect(response_json).to include("id" => site.id, "site_name" => "Hidden plot")

        get "/api/v2/landscapes/#{landscape.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:ok)
        expect(response_json["sites"].map { |row| row["site_id"] }).to include(site.id)
      end
    end

    it "does not accept without the site-data acknowledgement" do
      invited = create(:organization)
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      invitation = create(:landscape_organization_invitation, invited_organization: invited)
      site = create(:site, landscape: invitation.landscape)
      member = add_member(invited, "member.one@wetlands.org")

      expect {
        patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
          params: {status: "accepted", site_data_acknowledged: false},
          headers: auth_headers(admin),
          as: :json
      }.not_to have_enqueued_job(LandscapeOrganizationInvitationNotificationJob)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["site_data_acknowledged"]).to include("must be accepted")
      expect(invitation.reload.status).to eq("pending")
      expect(invitation.site_data_acknowledged_at).to be_nil
      expect(LandscapesOrganizations.exists?(landscape: invitation.landscape, organization: invited)).to be(false)

      get "/api/v2/sites/#{site.id}", headers: auth_headers(member)
      expect(response).to have_http_status(:forbidden)
    end

    it "declines without linking the organization or revealing its sites" do
      landscape = create(:landscape, landscape_name: "Sundarbans")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      invited = create(:organization, organization_name: "Coastal Alliance")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      member = add_member(invited, "member.one@wetlands.org")
      site = create(:site, landscape: landscape, site_name: "Hidden plot")
      invitation = create(
        :landscape_organization_invitation,
        landscape: landscape,
        inviting_organization: inviting,
        invited_organization: invited,
        invited_by: inviter
      )

      expect {
        patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
          params: {status: "declined"},
          headers: auth_headers(admin),
          as: :json
      }.to have_enqueued_job(LandscapeOrganizationInvitationNotificationJob).exactly(2).times

      expect(response).to have_http_status(:ok)
      expect(response_json).to include("status" => "declined", "site_data_acknowledged_at" => nil)
      expect(response_json["responded_at"]).to be_present
      expect(LandscapesOrganizations.exists?(landscape: landscape, organization: invited)).to be(false)

      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly([admin.email], [inviter.email])
      ActionMailer::Base.deliveries.each do |mail|
        content = mail_content(mail)
        expect(content).to include("was declined")
        expect(content).not_to include("can now see")
        expect(content).not_to include(inviter.email)
        expect(content).not_to include(admin.email)
      end

      get "/api/v2/sites/#{site.id}", headers: auth_headers(member)
      expect(response).to have_http_status(:forbidden)

      get "/api/v2/landscapes/#{landscape.id}", headers: auth_headers(member)
      expect(response).to have_http_status(:forbidden)

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(inviter),
        as: :json
      expect(response).to have_http_status(:created)
    end

    it "rejects a second decision and an unknown status" do
      invited = create(:organization)
      admin = add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")
      invitation = create(:landscape_organization_invitation, invited_organization: invited)

      patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
        params: {status: "maybe"},
        headers: auth_headers(admin),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["status"]).to include("must be accepted or declined")
      expect(invitation.reload.status).to eq("pending")

      patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
        params: {status: "declined"},
        headers: auth_headers(admin),
        as: :json
      expect(response).to have_http_status(:ok)

      expect {
        patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
          params: {status: "accepted", site_data_acknowledged: true},
          headers: auth_headers(admin),
          as: :json
      }.not_to change { LandscapesOrganizations.where(organization: invited).count }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["status"]).to include("must be a pending invitation")
      expect(invitation.reload.status).to eq("declined")
    end
  end

  describe "authorization" do
    it "returns 403 for anyone who is not an admin of an organization on the landscape, including platform admins" do
      landscape = create(:landscape, landscape_name: "Secret Landscape")
      inviting = create(:organization, organization_name: "Mangrove Partnership")
      outsider_org = create(:organization, organization_name: "Outsider Org")
      invited = create(:organization, organization_name: "Coastal Alliance")
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      inviter = add_admin(inviting, "ada.admin@wetlands.org", "Ada Admin")
      member = add_member(inviting, "member.user@wetlands.org")
      outsider_admin = add_admin(outsider_org, "outsider.admin@wetlands.org", "Outsider Admin")
      staff = create(:user, email: "staff.user@wetlands.org", admin: true)
      add_admin(invited, "bao.admin@wetlands.org", "Bao Admin")

      [member, outsider_admin, staff].each do |user|
        expect {
          post "/api/v2/landscapes/#{landscape.id}/invitations",
            params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
            headers: auth_headers(user),
            as: :json
        }.not_to change(LandscapeOrganizationInvitation, :count)

        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include("Secret Landscape")
      end

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: outsider_org.id, invited_organization_id: invited.id},
        headers: auth_headers(outsider_admin),
        as: :json
      expect(response).to have_http_status(:forbidden)

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(inviter),
        as: :json
      invitation = LandscapeOrganizationInvitation.find(response_json["id"])

      [member, outsider_admin, staff, inviter].each do |user|
        get "/api/v2/organizations/#{invited.id}/landscape_invitations", headers: auth_headers(user)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include("Secret Landscape")

        patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
          params: {status: "accepted", site_data_acknowledged: true},
          headers: auth_headers(user),
          as: :json
        expect(response).to have_http_status(:forbidden)
        expect(invitation.reload.status).to eq("pending")
      end
    end

    it "blocks an org admin who has not acknowledged their name" do
      landscape = create(:landscape, landscape_name: "Secret Landscape")
      inviting = create(:organization)
      invited = create(:organization)
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting)
      unacknowledged_inviter = create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
      OrganizationsUsers.create!(organization: inviting, user: unacknowledged_inviter, role: "org-admin")
      unacknowledged_invitee = create(:user, name: "Bao Admin", email: "bao.admin@wetlands.org")
      OrganizationsUsers.create!(organization: invited, user: unacknowledged_invitee, role: "org-admin")
      inviter = add_admin(inviting, "erin.admin@wetlands.org", "Erin Admin")
      invitation = create(
        :landscape_organization_invitation,
        landscape: landscape,
        inviting_organization: inviting,
        invited_organization: invited,
        invited_by: inviter
      )

      post "/api/v2/landscapes/#{landscape.id}/invitations",
        params: {inviting_organization_id: inviting.id, invited_organization_id: invited.id},
        headers: auth_headers(unacknowledged_inviter),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")

      get "/api/v2/organizations/#{invited.id}/landscape_invitations", headers: auth_headers(unacknowledged_invitee)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(response.body).not_to include("Secret Landscape")

      patch "/api/v2/organizations/#{invited.id}/landscape_invitations/#{invitation.id}",
        params: {status: "accepted", site_data_acknowledged: true},
        headers: auth_headers(unacknowledged_invitee),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(invitation.reload.status).to eq("pending")
      expect(LandscapesOrganizations.exists?(landscape: landscape, organization: invited)).to be(false)
    end
  end

  describe "api v3" do
    it "does not expose invitation routes" do
      landscape = create(:landscape)
      organization = create(:organization)
      admin = add_admin(organization, "bao.admin@wetlands.org", "Bao Admin")
      invitation = create(:landscape_organization_invitation, invited_organization: organization)

      expect {
        post "/api/v3/landscapes/#{landscape.id}/invitations",
          params: {inviting_organization_id: organization.id, invited_organization_id: organization.id},
          headers: auth_headers(admin),
          as: :json
      }.to raise_error(ActionController::RoutingError)

      expect {
        get "/api/v3/organizations/#{organization.id}/landscape_invitations", headers: auth_headers(admin)
      }.to raise_error(ActionController::RoutingError)

      expect {
        patch "/api/v3/organizations/#{organization.id}/landscape_invitations/#{invitation.id}",
          params: {status: "accepted", site_data_acknowledged: true},
          headers: auth_headers(admin),
          as: :json
      }.to raise_error(ActionController::RoutingError)

      expect(invitation.reload.status).to eq("pending")
    end
  end

  def add_admin(organization, email, name)
    admin = create(:user, email: email, name: name)
    OrganizationsUsers.create!(
      organization: organization,
      user: admin,
      role: "org-admin",
      admin_name_acknowledged_at: Time.current
    )
    admin
  end

  def add_member(organization, email)
    member = create(:user, email: email)
    OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
    member
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end

  def expect_no_emails(*emails)
    emails.each { |email| expect(response.body).not_to include(email) }
    expect(response.body).not_to include("\"email\"")
  end

  def mail_content(mail)
    [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
  end
end

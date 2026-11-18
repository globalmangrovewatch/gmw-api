require "rails_helper"

RSpec.describe "Organization join requests", type: :request do
  include ActiveJob::TestHelper

  describe "POST /api/v2/organizations/:id/join_requests" do
    it "requires a signed-in user" do
      organization = create(:organization)

      post "/api/v2/organizations/#{organization.id}/join_requests",
        params: {message: "I work on restoration"},
        as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(OrganizationJoinRequest.count).to eq(0)
    end

    it "creates one pending request for a signed-in non-member and emails each org admin" do
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      other_admin = add_admin(organization, "bao.admin@wetlands.org", "Bao Admin")

      expect {
        post "/api/v2/organizations/#{organization.id}/join_requests",
          params: {message: "I work on restoration"},
          headers: auth_headers(requester),
          as: :json
      }.to have_enqueued_job(OrganizationJoinRequestNotificationJob).exactly(2).times

      expect(response).to have_http_status(:created)
      expect(response_json).to include(
        "organization_id" => organization.id,
        "organization_name" => "Mangrove Partnership",
        "status" => "pending",
        "message" => "I work on restoration",
        "requester_name" => "Ana Requester",
        "reviewed_at" => nil
      )
      expect_no_emails(requester.email, admin.email, other_admin.email)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly([admin.email], [other_admin.email])
      ActionMailer::Base.deliveries.each do |mail|
        content = mail_content(mail)
        expect(content).to include("Ana Requester")
        expect(content).to include("I work on restoration")
        expect(content).to include("Mangrove Partnership")
        expect(content).not_to include(requester.email)
        expect(content).not_to include(admin.email)
        expect(content).not_to include(other_admin.email)
      end
    end

    it "rejects a member and a second pending request" do
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      organization = create(:organization, organization_name: "Mangrove Partnership")
      add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      OrganizationsUsers.create!(organization: organization, user: requester, role: "org-user")

      expect {
        post "/api/v2/organizations/#{organization.id}/join_requests",
          params: {message: "I work on restoration"},
          headers: auth_headers(requester),
          as: :json
      }.not_to change(OrganizationJoinRequest, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["user"]).to include("is already a member of this organization")

      outsider = create(:user, name: "Outsider", email: "outsider@wetlands.org")
      post "/api/v2/organizations/#{organization.id}/join_requests",
        params: {message: "Please add me"},
        headers: auth_headers(outsider),
        as: :json
      expect(response).to have_http_status(:created)

      expect {
        post "/api/v2/organizations/#{organization.id}/join_requests",
          params: {message: "Please add me again"},
          headers: auth_headers(outsider),
          as: :json
      }.not_to change(OrganizationJoinRequest, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["user"]).to include("already has a pending request")
    end

    it "does not put an email-shaped name in the response" do
      requester = create(:user, name: "ana.requester@wetlands.org", email: "ana.requester@wetlands.org")
      organization = create(:organization, organization_name: "Mangrove Partnership")
      add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")

      post "/api/v2/organizations/#{organization.id}/join_requests",
        params: {message: "I work on restoration"},
        headers: auth_headers(requester),
        as: :json

      expect(response).to have_http_status(:created)
      expect(response_json["requester_name"]).to be_nil
      expect(response.body).not_to include("ana.requester@wetlands.org")
      expect(response.body).not_to include("ada.admin@wetlands.org")
    end
  end

  describe "GET /api/v2/users/current_user/join_requests" do
    it "returns only the requester's requests and their status" do
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      someone_else = create(:user, name: "Other Person", email: "other.person@wetlands.org")
      organization = create(:organization, organization_name: "Mangrove Partnership")
      other_organization = create(:organization, organization_name: "Coastal Alliance")
      own_request = create(:organization_join_request, organization: organization, user: requester, message: "I work on restoration")
      create(:organization_join_request, organization: other_organization, user: someone_else, message: "Secret message")

      get "/api/v2/users/current_user/join_requests", headers: auth_headers(requester)

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq([
        {
          "id" => own_request.id,
          "organization_id" => organization.id,
          "organization_name" => "Mangrove Partnership",
          "status" => "pending",
          "message" => "I work on restoration",
          "created_at" => own_request.created_at.as_json,
          "reviewed_at" => nil
        }
      ])
      expect_no_emails(requester.email, someone_else.email)
      expect(response.body).not_to include("Secret message")
      expect(response.body).not_to include("Other Person")
    end
  end

  describe "GET /api/v2/organizations/:id/join_requests" do
    it "lists pending requests with name and message for an acknowledged org admin" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      pending = create(:organization_join_request, organization: organization, user: requester, message: "I work on restoration")
      rejected_user = create(:user, name: "Rejected Person", email: "rejected.person@wetlands.org")
      create(:organization_join_request, organization: organization, user: rejected_user, status: "rejected", message: "Too late")

      get "/api/v2/organizations/#{organization.id}/join_requests", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq([
        {
          "id" => pending.id,
          "status" => "pending",
          "message" => "I work on restoration",
          "requester_name" => "Ana Requester",
          "created_at" => pending.created_at.as_json
        }
      ])
      expect_no_emails(requester.email, admin.email, rejected_user.email)
      expect(response.body).not_to include("Too late")
      expect(response.body).not_to include("Rejected Person")
    end

    it "returns 403 for non-admins, including platform admins who are not org admins" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      member = create(:user, email: "member.user@wetlands.org")
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
      outsider = create(:user, email: "outsider@wetlands.org")
      staff = create(:user, email: "staff.user@wetlands.org", admin: true)
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)

      [member, outsider, staff].each do |user|
        get "/api/v2/organizations/#{organization.id}/join_requests", headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include("Ana Requester")
        expect(response.body).not_to include(requester.email)

        patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
          params: {status: "approved"},
          headers: auth_headers(user),
          as: :json

        expect(response).to have_http_status(:forbidden)
        expect(join_request.reload.status).to eq("pending")
      end
    end

    it "blocks an org admin who has not acknowledged their name" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
      OrganizationsUsers.create!(organization: organization, user: admin, role: "org-admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)

      get "/api/v2/organizations/#{organization.id}/join_requests", headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(response.body).not_to include(requester.email)

      patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
        params: {status: "approved"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(join_request.reload.status).to eq("pending")
      expect(OrganizationsUsers.where(user: requester)).to be_empty
    end
  end

  describe "PATCH /api/v2/organizations/:id/join_requests/:request_id" do
    it "approves a pending request, creates an org-user, and emails only the requester" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      other_admin = add_admin(organization, "bao.admin@wetlands.org", "Bao Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester, message: "I work on restoration")

      expect {
        patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
          params: {status: "approved"},
          headers: auth_headers(admin),
          as: :json
      }.to have_enqueued_job(OrganizationJoinRequestNotificationJob).with(join_request.id, "decided", requester.id)

      expect(response).to have_http_status(:ok)
      expect(response_json["status"]).to eq("approved")
      expect(response_json["requester_name"]).to eq("Ana Requester")
      expect_no_emails(requester.email, admin.email, other_admin.email)

      membership = OrganizationsUsers.find_by!(organization: organization, user: requester)
      expect(membership.role).to eq("org-user")
      expect(join_request.reload.reviewed_by).to eq(admin)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to eq([[requester.email]])
      content = mail_content(ActionMailer::Base.deliveries.last)
      expect(content).to include("was approved")
      expect(content).to include("Mangrove Partnership")
      expect(content).not_to include(admin.email)
      expect(content).not_to include(other_admin.email)
      expect(content).not_to include(requester.email)
      expect(content).not_to include("Ada Admin")
      expect(content).not_to include("Bao Admin")
    end

    it "rejects a request without creating a membership and emails the requester" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)

      expect {
        patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
          params: {status: "rejected"},
          headers: auth_headers(admin),
          as: :json
      }.not_to change(OrganizationsUsers, :count)

      expect(response).to have_http_status(:ok)
      expect(join_request.reload.status).to eq("rejected")
      expect_no_emails(requester.email, admin.email)

      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.map(&:to)).to eq([[requester.email]])
      expect(mail_content(ActionMailer::Base.deliveries.last)).to include("was rejected")
      expect(mail_content(ActionMailer::Base.deliveries.last)).not_to include(admin.email)
    end

    it "lets the user request again after a rejection" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)
      join_request.review("rejected", reviewer: admin)

      post "/api/v2/organizations/#{organization.id}/join_requests",
        params: {message: "Trying again"},
        headers: auth_headers(requester),
        as: :json

      expect(response).to have_http_status(:created)
      expect(response_json["status"]).to eq("pending")
      expect(OrganizationJoinRequest.pending.where(organization: organization, user: requester).count).to eq(1)
    end

    it "does not approve an invalid or already reviewed request" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)

      patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
        params: {status: "pending"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(join_request.reload.status).to eq("pending")
      expect(OrganizationsUsers.where(user: requester)).to be_empty

      join_request.review("rejected", reviewer: admin)

      patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
        params: {status: "approved"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(join_request.reload.status).to eq("rejected")
      expect(OrganizationsUsers.where(user: requester)).to be_empty
    end

    it "does not review a request from another organization" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      other_organization = create(:organization, organization_name: "Coastal Alliance")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: other_organization, user: requester)

      patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
        params: {status: "approved"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:not_found)
      expect(join_request.reload.status).to eq("pending")
      expect(OrganizationsUsers.where(user: requester)).to be_empty
    end

    it "keeps the request pending when membership creation fails" do
      organization = create(:organization, organization_name: "Mangrove Partnership")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      requester = create(:user, name: "Ana Requester", email: "ana.requester@wetlands.org")
      join_request = create(:organization_join_request, organization: organization, user: requester)
      allow(OrganizationsUsers).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique.new("duplicate"))

      expect {
        patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
          params: {status: "approved"},
          headers: auth_headers(admin),
          as: :json
      }.not_to have_enqueued_job(OrganizationJoinRequestNotificationJob)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(join_request.reload.status).to eq("pending")
      expect(OrganizationsUsers.where(user: requester)).to be_empty
    end
  end

  describe "authentication" do
    it "requires a signed-in user on every join request endpoint" do
      organization = create(:organization)
      requester = create(:user)
      join_request = create(:organization_join_request, organization: organization, user: requester)

      get "/api/v2/users/current_user/join_requests"
      expect(response).to have_http_status(:unauthorized)

      get "/api/v2/organizations/#{organization.id}/join_requests"
      expect(response).to have_http_status(:unauthorized)

      patch "/api/v2/organizations/#{organization.id}/join_requests/#{join_request.id}",
        params: {status: "approved"},
        as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(join_request.reload.status).to eq("pending")
    end
  end

  describe "api v3" do
    it "does not expose join request routes" do
      requester = create(:user)
      organization = create(:organization)
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      join_request = create(:organization_join_request, organization: organization, user: requester)

      expect {
        post "/api/v3/organizations/#{organization.id}/join_requests",
          params: {message: "Hello"},
          headers: auth_headers(requester),
          as: :json
      }.to raise_error(ActionController::RoutingError)

      expect {
        get "/api/v3/organizations/#{organization.id}/join_requests", headers: auth_headers(admin)
      }.to raise_error(ActionController::RoutingError)

      expect {
        patch "/api/v3/organizations/#{organization.id}/join_requests/#{join_request.id}",
          params: {status: "approved"},
          headers: auth_headers(admin),
          as: :json
      }.to raise_error(ActionController::RoutingError)

      expect {
        get "/api/v3/users/current_user/join_requests", headers: auth_headers(requester)
      }.to raise_error(ActionController::RoutingError)

      expect(join_request.reload.status).to eq("pending")
      expect(OrganizationJoinRequest.count).to eq(1)
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

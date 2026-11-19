require "rails_helper"

RSpec.describe "GMA membership validation", type: :request do
  include ActiveJob::TestHelper

  before do
    ActionMailer::Base.default_url_options[:host] = "example.com"
    CountryRegion.import_reference_data!
  end

  describe "GET /api/v2/gma/organizations" do
    it "lists pending claims for a GMA validator" do
      validator = create(:user, gma_validator: true, email: "validator.list@gma.org")
      spain = country("Spain", "ESP", "spain-gma-review")
      kenya = country("Kenya", "KEN", "kenya-gma-review")
      pending = create_claim("Pending Chapter", [spain, kenya], "national_chapter", "Kenya Chapter")
      verified = create_claim("Verified Coast", [spain], "member")
      verified.review_gma_membership!("verify", reviewer: validator)
      rejected = create_claim("Rejected Coast", [kenya], "national_chapter", "Hidden Chapter")
      rejected.review_gma_membership!("reject", reviewer: validator, reason: "Not a member")
      create_claim("No Claim", [spain], "none")
      add_admin(pending, "secret.admin@wetlands.org")

      get "/api/v2/gma/organizations", params: {status: "pending"}, headers: auth_headers(validator)

      expect(response).to have_http_status(:ok)
      expect(response_json.map { |row| row["id"] }).to eq([pending.id])
      row = response_json.first
      expect(row["organization_name"]).to eq("Pending Chapter")
      expect(row["regions"]).to eq(["Africa", "Europe"])
      expect(row["gma_membership"]).to eq("national_chapter")
      expect(row["gma_chapter_name"]).to eq("Kenya Chapter")
      expect(row["gma_status"]).to eq("pending")
      expect(row["created_at"]).to eq(pending.created_at.as_json)
      expect(response.body).not_to include("secret.admin@wetlands.org")
      expect(response.body).not_to include("Verified Coast")
      expect(response.body).not_to include("Hidden Chapter")
      expect(response.body).not_to include("No Claim")
      expect(response.body).not_to include(validator.email)
    end

    it "defaults to pending and can list verified or rejected claims" do
      validator = create(:user, gma_validator: true)
      spain = country("Spain", "ESP", "spain-gma-queue")
      pending = create_claim("Still Pending", [spain], "member")
      verified = create_claim("Already Verified", [spain], "member")
      verified.review_gma_membership!("verify", reviewer: validator)
      rejected = create_claim("Already Rejected", [spain], "national_chapter", "Spain Chapter")
      rejected.review_gma_membership!("reject", reviewer: validator)

      get "/api/v2/gma/organizations", headers: auth_headers(validator)

      expect(response).to have_http_status(:ok)
      expect(response_json.map { |row| row["id"] }).to eq([pending.id])

      get "/api/v2/gma/organizations", params: {status: "verified"}, headers: auth_headers(validator)

      expect(response_json.map { |row| row["id"] }).to eq([verified.id])
      expect(response_json.first["gma_status"]).to eq("verified")

      get "/api/v2/gma/organizations", params: {status: "rejected"}, headers: auth_headers(validator)

      expect(response_json.map { |row| row["id"] }).to eq([rejected.id])
      expect(response_json.first["gma_chapter_name"]).to eq("Spain Chapter")
    end

    it "rejects an unknown status" do
      validator = create(:user, gma_validator: true)

      get "/api/v2/gma/organizations", params: {status: "all"}, headers: auth_headers(validator)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["status"]).to include("must be pending, verified, or rejected")
    end
  end

  describe "PATCH /api/v2/gma/organizations/:id" do
    it "verifies a pending claim, shows it to every user, and emails the org admins" do
      validator = create(:user, gma_validator: true, email: "validator.review@gma.org", name: "Val Reviewer")
      outsider = create(:user, email: "outsider.review@example.com")
      member = create(:user, email: "member.review@wetlands.org", name: "Member Person")
      spain = country("Spain", "ESP", "spain-gma-verify")
      organization = create_claim("Pending Chapter", [spain], "national_chapter", "Spain Chapter")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      other_admin = add_admin(organization, "bao.admin@wetlands.org", "Bao Admin")
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      expect {
        patch "/api/v2/gma/organizations/#{organization.id}",
          params: {decision: "verify", reason: "  Membership confirmed  "},
          headers: auth_headers(validator),
          as: :json
      }.to have_enqueued_job(GmaMembershipReviewNotificationJob).exactly(2).times

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_status"]).to eq("verified")
      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_chapter_name"]).to eq("Spain Chapter")
      expect(response_json["gma_review_reason"]).to eq("Membership confirmed")
      expect(response_json["gma_reviewed_by_id"]).to eq(validator.id)
      expect(response_json["gma_reviewed_at"]).to eq(organization.reload.gma_reviewed_at.as_json)
      expect(response_json["regions"]).to eq(["Europe"])
      expect(response.body).not_to include(validator.email)
      expect(response.body).not_to include(admin.email)
      expect(organization.gma_reviewed_by).to eq(validator)

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response_json["gma_member"]).to eq("GMA member")
      expect(response_json).not_to have_key("gma_membership")
      expect(response_json).not_to have_key("gma_status")
      expect(response_json).not_to have_key("gma_chapter_name")
      expect(response.body).not_to include("Spain Chapter")

      get "/api/v2/organizations", params: {q: "Pending Chapter"}, headers: auth_headers(outsider)

      listed = response_json["data"].find { |row| row["id"] == organization.id }
      expect(listed["gma_member"]).to eq("GMA member")
      expect(listed).not_to have_key("gma_chapter_name")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(member)

      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_status"]).to eq("verified")
      expect(response_json["gma_chapter_name"]).to eq("Spain Chapter")
      expect(response_json).not_to have_key("gma_member")

      get "/api/v3/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:ok)
      expect(response_json.keys.grep(/\Agma_/)).to eq([])
      expect(response.body).not_to include("GMA member")
      expect(response.body).not_to include("Spain Chapter")

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly([admin.email], [other_admin.email])
      ActionMailer::Base.deliveries.each do |mail|
        content = mail_content(mail)
        expect(content).to include("GMA membership for Pending Chapter was verified")
        expect(content).to include("Membership confirmed")
        expect(content).not_to include(validator.email)
        expect(content).not_to include(validator.name)
        expect(content).not_to include(admin.email)
        expect(content).not_to include(other_admin.email)
        expect(content).not_to include(member.email)
      end
    end

    it "rejects a pending claim without showing it as a GMA member" do
      validator = create(:user, gma_validator: true, email: "validator.reject@gma.org", name: "Val Reviewer")
      outsider = create(:user, email: "outsider.reject@example.com")
      member = create(:user, email: "member.reject@wetlands.org")
      kenya = country("Kenya", "KEN", "kenya-gma-reject")
      organization = create_claim("Rejected Chapter", [kenya], "national_chapter", "Kenya Chapter")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      expect {
        patch "/api/v2/gma/organizations/#{organization.id}",
          params: {decision: "reject"},
          headers: auth_headers(validator),
          as: :json
      }.to have_enqueued_job(GmaMembershipReviewNotificationJob).with(organization.id, admin.id)

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_status"]).to eq("rejected")
      expect(response_json["gma_review_reason"]).to be_nil
      expect(organization.reload.gma_status).to eq("rejected")
      expect(organization.gma_reviewed_by).to eq(validator)
      expect(organization.gma_reviewed_at).to be_present

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response_json.keys.grep(/\Agma_/)).to eq([])
      expect(response.body).not_to include("Kenya Chapter")
      expect(response.body).not_to include("GMA member")
      expect(response.body).not_to include("rejected")

      get "/api/v2/organizations", params: {q: "Rejected Chapter"}, headers: auth_headers(outsider)

      listed = response_json["data"].find { |row| row["id"] == organization.id }
      expect(listed.keys.grep(/\Agma_/)).to eq([])

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(member)

      expect(response_json["gma_status"]).to eq("rejected")
      expect(response_json["gma_chapter_name"]).to eq("Kenya Chapter")
      expect(response_json).not_to have_key("gma_member")

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.map(&:to)).to eq([[admin.email]])
      content = mail_content(ActionMailer::Base.deliveries.last)
      expect(content).to include("was rejected")
      expect(content).not_to include("Reason:")
      expect(content).not_to include(validator.email)
      expect(content).not_to include(validator.name)
      expect(content).not_to include(admin.email)
      expect(content).not_to include(member.email)
    end

    it "does not review a claim that is not pending" do
      validator = create(:user, gma_validator: true)
      spain = country("Spain", "ESP", "spain-gma-again")
      organization = create_claim("Verified Coast", [spain], "member")
      organization.review_gma_membership!("verify", reviewer: validator, reason: "Confirmed")
      reviewed_at = organization.gma_reviewed_at

      expect {
        patch "/api/v2/gma/organizations/#{organization.id}",
          params: {decision: "reject", reason: "Changed mind"},
          headers: auth_headers(validator),
          as: :json
      }.not_to have_enqueued_job(GmaMembershipReviewNotificationJob)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["gma_status"]).to include("must be a pending claim")
      organization.reload
      expect(organization.gma_status).to eq("verified")
      expect(organization.gma_review_reason).to eq("Confirmed")
      expect(organization.gma_reviewed_at).to eq(reviewed_at)

      none = create_claim("No Claim", [spain], "none")

      patch "/api/v2/gma/organizations/#{none.id}",
        params: {decision: "verify"},
        headers: auth_headers(validator),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(none.reload.gma_status).to eq("unverified")
    end

    it "rejects an unknown decision" do
      validator = create(:user, gma_validator: true)
      spain = country("Spain", "ESP", "spain-gma-decision")
      organization = create_claim("Pending Coast", [spain], "member")

      expect {
        patch "/api/v2/gma/organizations/#{organization.id}",
          params: {decision: "approve"},
          headers: auth_headers(validator),
          as: :json
      }.not_to have_enqueued_job(GmaMembershipReviewNotificationJob)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["decision"]).to include("must be verify or reject")
      expect(organization.reload.gma_status).to eq("pending")
    end

    it "returns not found for a missing organization" do
      validator = create(:user, gma_validator: true)

      patch "/api/v2/gma/organizations/0",
        params: {decision: "verify"},
        headers: auth_headers(validator),
        as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authorization" do
    it "lets only GMA validators list and review" do
      spain = country("Spain", "ESP", "spain-gma-auth")
      organization = create_claim("Pending Coast", [spain], "member")
      org_admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")
      platform_admin = create(:user, admin: true, gma_validator: false, email: "platform.admin@gmw.org")
      member = create(:user)
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      get "/api/v2/gma/organizations"

      expect(response).to have_http_status(:unauthorized)

      [org_admin, platform_admin, member].each do |user|
        get "/api/v2/gma/organizations", params: {status: "nope"}, headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
        expect(response_json["message"]).to eq("Insufficient privilege")

        patch "/api/v2/gma/organizations/#{organization.id}",
          params: {decision: "verify"},
          headers: auth_headers(user),
          as: :json

        expect(response).to have_http_status(:forbidden)
        expect(organization.reload.gma_status).to eq("pending")
      end

      patch "/api/v2/gma/organizations/0",
        params: {decision: "verify"},
        headers: auth_headers(platform_admin),
        as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "does not let an org admin or a validator set the decision through the organization update" do
      spain = country("Spain", "ESP", "spain-gma-bypass")
      validator = create(:user, gma_validator: true, email: "validator.bypass@gma.org")
      organization = create_claim("Pending Coast", [spain], "member")
      OrganizationsUsers.create!(
        organization: organization,
        user: validator,
        role: "org-admin",
        admin_name_acknowledged_at: Time.current
      )

      patch "/api/v2/organizations/#{organization.id}",
        params: {
          gma_status: "verified",
          gma_reviewed_by_id: validator.id,
          gma_review_reason: "Self approved"
        },
        headers: auth_headers(validator),
        as: :json

      expect(response).to have_http_status(:ok)
      organization.reload
      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_reviewed_by_id).to be_nil
      expect(organization.gma_review_reason).to be_nil
    end

    it "hides a verified organization again when its claim changes" do
      validator = create(:user, gma_validator: true)
      outsider = create(:user, email: "outsider.reclaim@example.com")
      spain = country("Spain", "ESP", "spain-gma-reclaim")
      organization = create_claim("Claimed Coast", [spain], "national_chapter", "Spain Chapter")
      admin = add_admin(organization, "ada.admin@wetlands.org", "Ada Admin")

      patch "/api/v2/gma/organizations/#{organization.id}",
        params: {decision: "verify", reason: "Confirmed"},
        headers: auth_headers(validator),
        as: :json

      expect(response).to have_http_status(:ok)

      patch "/api/v2/organizations/#{organization.id}",
        params: {gma_chapter_name: "Iberian Chapter"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_status"]).to eq("pending")
      organization.reload
      expect(organization.gma_reviewed_by).to be_nil
      expect(organization.gma_reviewed_at).to be_nil
      expect(organization.gma_review_reason).to be_nil

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response_json.keys.grep(/\Agma_/)).to eq([])
      expect(response.body).not_to include("GMA member")
      expect(response.body).not_to include("Iberian Chapter")
    end
  end

  describe "who can become a validator" do
    it "ignores the flag on signup" do
      post "/users", params: {
        user: {
          email: "new.validator@example.com",
          password: "password123",
          name: "New User",
          gma_validator: true
        }
      }, as: :json

      created = User.find_by!(email: "new.validator@example.com")
      expect(created.gma_validator).to be(false)
      expect(response_json["user"]["gma_validator"]).to be(false)
    end

    it "ignores the flag on profile update" do
      user = create(:user, gma_validator: false, email: "profile.validator@example.com")

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          gma_validator: true
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["email"]).to eq(user.email)
      expect(response_json["user"]["gma_validator"]).to be(false)
      expect(user.reload.gma_validator).to be(false)
    end

    it "tells the current user whether they can validate GMA membership" do
      validator = create(:user, gma_validator: true)

      get "/users/current_user", headers: auth_headers(validator)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["gma_validator"]).to be(true)
    end
  end

  describe "api v3" do
    it "has no GMA review routes" do
      validator = create(:user, gma_validator: true)

      expect {
        get "/api/v3/gma/organizations", headers: auth_headers(validator)
      }.to raise_error(ActionController::RoutingError)

      expect {
        patch "/api/v3/gma/organizations/1",
          params: {decision: "verify"},
          headers: auth_headers(validator),
          as: :json
      }.to raise_error(ActionController::RoutingError)
    end
  end

  def create_claim(name, countries, membership, chapter_name = nil)
    Organization.create!(
      organization_name: name,
      country_location_ids: countries.map(&:location_id),
      gma_membership: membership,
      gma_chapter_name: chapter_name
    )
  end

  def add_admin(organization, email, name = "Org Admin")
    admin = create(:user, email: email, name: name)
    OrganizationsUsers.create!(
      organization: organization,
      user: admin,
      role: "org-admin",
      admin_name_acknowledged_at: Time.current
    )
    admin
  end

  def country(name, iso, location_id)
    Location.create!(
      name: name,
      location_type: "country",
      iso: iso,
      location_id: location_id,
      bounds: {},
      geometry: {}
    )
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end

  def mail_content(mail)
    [mail.subject, mail.text_part.body.to_s, mail.html_part.body.to_s].join("\n")
  end
end

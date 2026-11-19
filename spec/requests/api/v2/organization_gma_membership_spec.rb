require "rails_helper"

RSpec.describe "Organization GMA membership", type: :request do
  include Devise::Test::IntegrationHelpers

  before do
    CountryRegion.import_reference_data!
  end

  describe "POST /api/v2/organizations" do
    it "saves a membership claim with gma_status pending" do
      user = create(:user)
      spain = country("Spain", "ESP", "spain")

      post "/api/v2/organizations",
        params: {
          organization_name: "GMA Coast",
          country_location_ids: [spain.location_id],
          admin_name_acknowledged: true,
          gma_membership: "member",
          gma_status: "verified",
          gma_chapter_name: "Should be ignored"
        },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_membership"]).to eq("member")
      expect(response_json["gma_status"]).to eq("pending")
      expect(response_json["gma_chapter_name"]).to be_nil
      expect(response_json).not_to have_key("gma_member")

      organization = Organization.find(response_json["id"])
      expect(organization.gma_membership).to eq("member")
      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_chapter_name).to be_nil
    end

    it "saves a national chapter claim as pending" do
      user = create(:user)
      kenya = country("Kenya", "KEN", "kenya")

      post "/api/v2/organizations",
        params: {
          organization_name: "Kenya Chapter Org",
          country_location_ids: [kenya.location_id],
          admin_name_acknowledged: true,
          gma_membership: "national_chapter",
          gma_chapter_name: "  Kenya Chapter  "
        },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_status"]).to eq("pending")
      expect(response_json["gma_chapter_name"]).to eq("Kenya Chapter")
    end

    it "rejects an unknown membership and creates nothing" do
      user = create(:user)
      spain = country("Spain", "ESP", "spain")

      post "/api/v2/organizations",
        params: {
          organization_name: "Not a Claim",
          country_location_ids: [spain.location_id],
          admin_name_acknowledged: true,
          gma_membership: "yes"
        },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["gma_membership"]).to include("is not included in the list")
      expect(Organization.count).to eq(0)
    end
  end

  describe "PATCH /api/v2/organizations/:id" do
    it "lets an org admin change the claim and resets it to pending" do
      spain = country("Spain", "ESP", "spain")
      admin = create(:user, email: "gma.admin@wetlands.org")
      organization = create_organization(
        "Claimed Coast",
        [spain],
        user: admin,
        role: "org-admin",
        admin_name_acknowledged_at: Time.current
      )
      organization.update_columns(gma_membership: "member", gma_status: "verified")

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Claimed Coast renamed", country_location_ids: [spain.location_id]},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_membership"]).to eq("member")
      expect(response_json["gma_status"]).to eq("verified")
      expect(organization.reload.gma_status).to eq("verified")

      patch "/api/v2/organizations/#{organization.id}",
        params: {
          gma_membership: "national_chapter",
          gma_chapter_name: "Spain Chapter",
          gma_status: "verified"
        },
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_status"]).to eq("pending")
      expect(response_json["gma_chapter_name"]).to eq("Spain Chapter")
      expect(response_json).not_to have_key("gma_member")
      organization.reload
      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_chapter_name).to eq("Spain Chapter")

      organization.update_columns(gma_status: "verified")

      patch "/api/v2/organizations/#{organization.id}",
        params: {gma_chapter_name: "Iberian Chapter"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_status"]).to eq("pending")
      expect(organization.reload.gma_chapter_name).to eq("Iberian Chapter")

      patch "/api/v2/organizations/#{organization.id}",
        params: {gma_membership: "none"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_membership"]).to eq("none")
      expect(response_json["gma_status"]).to eq("unverified")
      expect(response_json["gma_chapter_name"]).to be_nil
      organization.reload
      expect(organization.gma_membership).to eq("none")
      expect(organization.gma_status).to eq("unverified")
      expect(organization.gma_chapter_name).to be_nil
    end

    it "rejects the change from a member who is not an org admin" do
      spain = country("Spain", "ESP", "spain")
      admin = create(:user)
      member = create(:user)
      organization = create_organization(
        "Members Only",
        [spain],
        user: admin,
        role: "org-admin",
        admin_name_acknowledged_at: Time.current
      )
      organization.update_columns(gma_membership: "member", gma_status: "verified")
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      patch "/api/v2/organizations/#{organization.id}",
        params: {gma_membership: "national_chapter", gma_chapter_name: "Spain Chapter"},
        headers: auth_headers(member),
        as: :json

      expect(response).to have_http_status(:forbidden)
      expect(organization.reload.gma_membership).to eq("member")
      expect(organization.gma_status).to eq("verified")
    end
  end

  describe "visibility" do
    it "hides an unverified claim from non-members and shows it to members" do
      spain = country("Spain", "ESP", "spain")
      member = create(:user, email: "member.gma@wetlands.org")
      outsider = create(:user, email: "outsider.gma@example.com")
      organization = create_organization("Hidden Claim", [spain], user: member, role: "org-user")
      organization.update_columns(
        gma_membership: "national_chapter",
        gma_status: "pending",
        gma_chapter_name: "Spain Chapter"
      )

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:ok)
      expect(gma_keys).to eq([])
      expect(response.body).not_to include("Spain Chapter")
      expect(response.body).not_to include("national_chapter")
      expect(response.body).not_to include("GMA member")

      get "/api/v2/organizations", headers: auth_headers(outsider)

      listed = response_json["data"].find { |row| row["id"] == organization.id }
      expect(listed.keys.grep(/\Agma_/)).to eq([])
      expect(response.body).not_to include("Spain Chapter")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(member)

      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_status"]).to eq("pending")
      expect(response_json["gma_chapter_name"]).to eq("Spain Chapter")
      expect(response_json).not_to have_key("gma_member")

      get "/api/v2/organizations", params: {q: "Hidden"}, headers: auth_headers(member)

      listed_for_member = response_json["data"].find { |row| row["id"] == organization.id }
      expect(listed_for_member["gma_membership"]).to eq("national_chapter")
      expect(listed_for_member["gma_status"]).to eq("pending")
      expect(listed_for_member["gma_chapter_name"]).to eq("Spain Chapter")

      organization.update_columns(gma_status: "rejected")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(gma_keys).to eq([])
      expect(response.body).not_to include("Spain Chapter")
      expect(response.body).not_to include("rejected")
    end

    it "shows non-members only GMA member when the claim is verified" do
      kenya = country("Kenya", "KEN", "kenya")
      member = create(:user, email: "verified.member@wetlands.org")
      outsider = create(:user, email: "verified.outsider@example.com", name: "Outside Person")
      organization = create_organization("Verified Chapter", [kenya], user: member, role: "org-admin", admin_name_acknowledged_at: Time.current)
      organization.update_columns(
        gma_membership: "national_chapter",
        gma_status: "verified",
        gma_chapter_name: "Kenya Chapter"
      )
      add_member(organization, "colleague@wetlands.org", name: "Colleague Name")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:ok)
      expect(response_json["gma_member"]).to eq("GMA member")
      expect(response_json).not_to have_key("gma_membership")
      expect(response_json).not_to have_key("gma_status")
      expect(response_json).not_to have_key("gma_chapter_name")
      expect(response.body).not_to include("Kenya Chapter")
      expect(response.body).not_to include("national_chapter")
      expect(response.body).not_to include("verified")

      get "/api/v2/organizations", params: {q: "Verified"}, headers: auth_headers(outsider)

      listed = response_json["data"].find { |row| row["id"] == organization.id }
      expect(listed["gma_member"]).to eq("GMA member")
      expect(listed).not_to have_key("gma_membership")
      expect(listed).not_to have_key("gma_chapter_name")

      get "/api/v2/organizations/suggested", headers: auth_headers(outsider)

      expect(response_json).to eq([])

      suggester = create(:user, email: "suggester@wetlands.org")

      get "/api/v2/organizations/suggested", headers: auth_headers(suggester)

      suggested = response_json.find { |row| row["id"] == organization.id }
      expect(suggested["gma_member"]).to eq("GMA member")
      expect(suggested).not_to have_key("gma_membership")
      expect(suggested).not_to have_key("gma_status")
      expect(suggested).not_to have_key("gma_chapter_name")
      expect(response.body).not_to include("Kenya Chapter")
      expect(response.body).not_to include("colleague@")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(member)

      expect(response_json["gma_membership"]).to eq("national_chapter")
      expect(response_json["gma_status"]).to eq("verified")
      expect(response_json["gma_chapter_name"]).to eq("Kenya Chapter")
      expect(response_json).not_to have_key("gma_member")
    end
  end

  describe "api v3" do
    it "does not accept or return GMA membership fields" do
      user = create(:user, name: "V3 Admin", email: "v3.gma.admin@wetlands.org")
      outsider = create(:user, email: "v3.gma.outsider@example.com")
      spain = country("Spain", "ESP", "spain-v3-gma")

      post "/api/v3/organizations",
        params: {
          organization_name: "V3 Coast",
          country_location_ids: [spain.location_id],
          gma_membership: "member",
          gma_status: "verified",
          gma_chapter_name: "Spain Chapter"
        },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(gma_keys).to eq([])
      organization = Organization.find(response_json["id"])
      expect(organization.gma_membership).to eq("none")
      expect(organization.gma_status).to eq("unverified")
      expect(organization.gma_chapter_name).to be_nil

      organization.update_columns(
        gma_membership: "national_chapter",
        gma_status: "verified",
        gma_chapter_name: "Spain Chapter"
      )

      get "/api/v3/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:ok)
      expect(gma_keys).to eq([])
      expect(response.body).not_to include("Spain Chapter")
      expect(response.body).not_to include("GMA member")
      expect(response.body).not_to include("national_chapter")

      get "/api/v3/organizations", headers: auth_headers(outsider)

      listed = response_json.find { |row| row["id"] == organization.id }
      expect(listed.keys.grep(/\Agma_/)).to eq([])
      expect(response.body).not_to include("Spain Chapter")
      expect(response.body).not_to include("GMA member")

      patch "/api/v3/organizations/#{organization.id}",
        params: {
          organization_name: "V3 Coast renamed",
          gma_membership: "member",
          gma_chapter_name: "Ignored Chapter"
        },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(gma_keys).to eq([])
      organization.reload
      expect(organization.organization_name).to eq("V3 Coast renamed")
      expect(organization.gma_membership).to eq("national_chapter")
      expect(organization.gma_status).to eq("verified")
      expect(organization.gma_chapter_name).to eq("Spain Chapter")
    end
  end

  def create_organization(name, countries, user: nil, role: nil, admin_name_acknowledged_at: nil)
    organization = Organization.create!(
      organization_name: name,
      country_location_ids: countries.map(&:location_id)
    )
    if user
      OrganizationsUsers.create!(
        organization: organization,
        user: user,
        role: role,
        admin_name_acknowledged_at: admin_name_acknowledged_at
      )
    end
    organization
  end

  def add_member(organization, email, name: "Member")
    member = create(:user, email: email, name: name)
    OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
    member
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

  def gma_keys
    response_json.keys.grep(/\Agma_/)
  end
end

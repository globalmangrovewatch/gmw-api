require "rails_helper"

RSpec.describe "Organization countries", type: :request do
  include Devise::Test::IntegrationHelpers

  before do
    CountryRegion.import_reference_data!
  end

  describe "POST /api/v2/organizations" do
    it "returns field errors without a name or without countries" do
      user = create(:user)

      post "/api/v2/organizations",
        params: {organization_name: "", country_location_ids: []},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["organization_name"]).to include("can't be blank")
      expect(response_json["errors"]["country_location_ids"]).to include("must include at least one country")
      expect(Organization.count).to eq(0)

      post "/api/v2/organizations",
        params: {organization_name: "Coastal Alliance"},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["country_location_ids"]).to include("must include at least one country")
      expect(response_json["errors"]).not_to have_key("organization_name")
    end

    it "rejects locations that are not countries" do
      user = create(:user)
      area = Location.create!(name: "Study area", location_type: "aoi", iso: "KEN", location_id: "aoi-1", bounds: {}, geometry: {})

      post "/api/v2/organizations",
        params: {organization_name: "Coastal Alliance", country_location_ids: [area.location_id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["country_location_ids"]).to include("must be country locations")
    end
  end

  it "returns countries and derived regions" do
    user = create(:user)
    kenya = country("Kenya", "KEN", "kenya")
    spain = country("Spain", "ESP", "spain")

    post "/api/v2/organizations",
      params: {
        organization_name: "Mangrove Partnership",
        country_location_ids: [kenya.location_id, spain.location_id]
      },
      headers: auth_headers(user),
      as: :json

    expect(response).to have_http_status(:ok)
    expect(response_json["organization_name"]).to eq("Mangrove Partnership")
    expect(response_json["countries"]).to eq([
      {"location_id" => "kenya", "iso" => "KEN", "name" => "Kenya"},
      {"location_id" => "spain", "iso" => "ESP", "name" => "Spain"}
    ])
    expect(response_json["regions"]).to eq(["Africa", "Europe"])
    expect(Organization.find(response_json["id"]).users).to include(user)

    get "/api/v2/organizations", headers: auth_headers(user)

    listed = response_json.find { |organization| organization["organization_name"] == "Mangrove Partnership" }
    expect(listed["regions"]).to eq(["Africa", "Europe"])
    expect(listed["countries"].pluck("iso")).to eq(["KEN", "ESP"])
  end

  describe "GET /countries and GET /regions" do
    it "lists countries with their region and the five M49 regions" do
      user = create(:user)
      country("Kenya", "KEN", "kenya")
      country("Spain", "ESP", "spain")
      Location.create!(name: "Study area", location_type: "aoi", iso: "KEN", location_id: "study-area", bounds: {}, geometry: {})

      get "/api/v2/countries", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json).to include(
        {"location_id" => "kenya", "iso" => "KEN", "name" => "Kenya", "region" => "Africa"},
        {"location_id" => "spain", "iso" => "ESP", "name" => "Spain", "region" => "Europe"}
      )
      expect(response_json.pluck("location_id")).not_to include("study-area")

      get "/api/v2/regions", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq(%w[Africa Americas Asia Europe Oceania])
    end
  end

  describe "existing organizations" do
    it "keeps working until countries are filled in" do
      user = create(:user)
      organization = Organization.new(organization_name: "Legacy Org")
      organization.save(validate: false)
      OrganizationsUsers.create!(organization: organization, user: user, role: "org-admin")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["organization_name"]).to eq("Legacy Org")
      expect(response_json["countries"]).to eq([])
      expect(response_json["regions"]).to eq([])

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Legacy Org renamed"},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["country_location_ids"]).to include("must include at least one country")
      expect(organization.reload.organization_name).to eq("Legacy Org")

      kenya = country("Kenya", "KEN", "kenya")

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Legacy Org", country_location_ids: [kenya.location_id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["countries"]).to eq([
        {"location_id" => "kenya", "iso" => "KEN", "name" => "Kenya"}
      ])
      expect(response_json["regions"]).to eq(["Africa"])

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Legacy Org renamed"},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["organization_name"]).to eq("Legacy Org renamed")
      expect(response_json["regions"]).to eq(["Africa"])
    end
  end

  describe "location re-import" do
    it "keeps organization countries when locations are re-imported" do
      user = create(:user)
      kenya = country("Kenya", "KEN", "kenya")
      spain = country("Spain", "ESP", "spain")
      original_ids = [kenya.id, spain.id]

      post "/api/v2/organizations",
        params: {
          organization_name: "Mangrove Partnership",
          country_location_ids: [kenya.location_id, spain.location_id]
        },
        headers: auth_headers(user),
        as: :json

      organization_id = response_json["id"]
      sign_in AdminUser.create!(email: "admin@example.com", password: "password123", role: :super_admin)

      file = Tempfile.new(["locations", ".csv"])
      file.write(<<~CSV)
        name,location_type,iso,location_id
        Kenya,country,KEN,kenya
        Spain,country,ESP,spain
      CSV
      file.rewind
      uploaded = Rack::Test::UploadedFile.new(file.path, "text/csv")

      expect {
        post do_import_admin_locations_path, params: {active_admin_import_model: {file: uploaded}}
      }.not_to change(OrganizationsCountry, :count)

      expect(response).to redirect_to(import_admin_locations_path)
      expect(Location.where(location_id: %w[kenya spain]).pluck(:id)).not_to match_array(original_ids)

      get "/api/v2/organizations/#{organization_id}", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["countries"]).to eq([
        {"location_id" => "kenya", "iso" => "KEN", "name" => "Kenya"},
        {"location_id" => "spain", "iso" => "ESP", "name" => "Spain"}
      ])
      expect(response_json["regions"]).to eq(["Africa", "Europe"])
    end
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
end

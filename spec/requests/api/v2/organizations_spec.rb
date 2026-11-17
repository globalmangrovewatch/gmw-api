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

    listed = response_json["data"].find { |organization| organization["organization_name"] == "Mangrove Partnership" }
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

  describe "GET /api/v2/organizations" do
    it "searches by name, orders A to Z, and keeps the current user's role" do
      user = create(:user)
      kenya = country("Kenya", "KEN", "kenya")
      spain = country("Spain", "ESP", "spain")
      create_organization("zeta trust", [spain])
      create_organization("Mangrove Alliance", [kenya], user: user, role: "org-user")
      create_organization("Coastal Mangroves", [spain])
      create_organization("beta forest", [spain], user: user, role: "org-admin")

      get "/api/v2/organizations", params: {q: "mang"}, headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(organization_names).to eq(["Coastal Mangroves", "Mangrove Alliance"])
      expect(response_json["meta"]).to eq("page" => 1, "per_page" => 25, "total" => 2)
      mangrove = response_json["data"].find { |organization| organization["organization_name"] == "Mangrove Alliance" }
      coastal = response_json["data"].find { |organization| organization["organization_name"] == "Coastal Mangroves" }
      expect(mangrove["role"]).to eq("org-user")
      expect(coastal["role"]).to be_nil

      get "/api/v2/organizations", params: {q: "MANG"}, headers: auth_headers(user)

      expect(organization_names).to eq(["Coastal Mangroves", "Mangrove Alliance"])

      get "/api/v2/organizations", headers: auth_headers(user)

      expect(organization_names).to eq(["beta forest", "Coastal Mangroves", "Mangrove Alliance", "zeta trust"])
      expect(response_json["data"].find { |organization| organization["organization_name"] == "beta forest" }["role"]).to eq("org-admin")
    end

    it "filters by region once per organization and by country iso" do
      user = create(:user)
      kenya = country("Kenya", "KEN", "kenya")
      tanzania = country("Tanzania", "TZA", "tanzania")
      spain = country("Spain", "ESP", "spain")
      australia = country("Australia", "AUS", "australia")
      create_organization("East Africa Partnership", [kenya, tanzania])
      create_organization("Kenya Spain Group", [kenya, spain])
      create_organization("Iberian Coast", [spain])
      create_organization("Pacific Mangroves", [australia])

      get "/api/v2/organizations", params: {region: "Africa"}, headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(organization_names).to eq(["East Africa Partnership", "Kenya Spain Group"])
      expect(response_json["meta"]["total"]).to eq(2)
      expect(response_json["data"].size).to eq(2)

      get "/api/v2/organizations", params: {region: "africa", q: "kenya"}, headers: auth_headers(user)

      expect(organization_names).to eq(["Kenya Spain Group"])

      get "/api/v2/organizations", params: {country: "esp"}, headers: auth_headers(user)

      expect(organization_names).to eq(["Iberian Coast", "Kenya Spain Group"])
    end

    it "paginates with page, per_page, and total" do
      user = create(:user)
      spain = country("Spain", "ESP", "spain")
      create_organization("c org", [spain])
      create_organization("a org", [spain])
      create_organization("b org", [spain])

      get "/api/v2/organizations", params: {page: 1, per_page: 2}, headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(organization_names).to eq(["a org", "b org"])
      expect(response_json["meta"]).to eq("page" => 1, "per_page" => 2, "total" => 3)

      get "/api/v2/organizations", params: {page: 2, per_page: 2}, headers: auth_headers(user)

      expect(organization_names).to eq(["c org"])
      expect(response_json["meta"]).to eq("page" => 2, "per_page" => 2, "total" => 3)

      get "/api/v2/organizations", params: {page: 3, per_page: 2}, headers: auth_headers(user)

      expect(organization_names).to eq([])
      expect(response_json["meta"]["total"]).to eq(3)
    end

    it "keeps the v3 index as a flat list" do
      user = create(:user)
      spain = country("Spain", "ESP", "spain")
      create_organization("Member Org", [spain], user: user, role: "org-admin")
      create_organization("Other Org", [spain])

      get "/api/v3/organizations", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json).to be_an(Array)
      member = response_json.find { |organization| organization["organization_name"] == "Member Org" }
      other = response_json.find { |organization| organization["organization_name"] == "Other Org" }
      expect(member["role"]).to eq("org-admin")
      expect(other["role"]).to be_nil
    end
  end

  describe "GET /api/v2/organizations/suggested" do
    it "suggests organizations whose members share the user's email domain" do
      user = create(:user, email: "ana@wetlands.org", name: "Ana Wetlands")
      spain = country("Spain", "ESP", "spain")
      kenya = country("Kenya", "KEN", "kenya")
      own = create_organization("Own Wetlands", [spain], user: user, role: "org-admin")
      add_member(own, "colleague@wetlands.org", name: "Colleague Name")
      match = create_organization("Mangrove Watch", [kenya])
      bob = add_member(match, "bob@wetlands.org", name: "Bob Watcher")
      bob.update_column(:email, "bob@Wetlands.ORG")
      add_member(match, "cara@wetlands.org", name: "Cara Watcher")
      add_member(match, "stray@gmail.com", name: "Stray Gmail")
      other = create_organization("Other Coast", [spain])
      add_member(other, "sam@other.org", name: "Sam Other")

      get "/api/v2/organizations/suggested", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq([
        {
          "id" => match.id,
          "organization_name" => "Mangrove Watch",
          "countries" => [{"location_id" => "kenya", "iso" => "KEN", "name" => "Kenya"}],
          "regions" => ["Africa"]
        }
      ])
      expect(response.body).not_to include("bob@")
      expect(response.body).not_to include("cara@")
      expect(response.body).not_to include("colleague@")
      expect(response.body).not_to include("stray@gmail.com")
      expect(response.body).not_to include("sam@other.org")
      expect(response.body).not_to include("Bob Watcher")
      expect(response.body).not_to include("Cara Watcher")
      expect(response.body).not_to include("Colleague Name")
      expect(response.body).not_to include("Stray Gmail")
      expect(response.body).not_to include("Sam Other")
    end

    it "returns an empty list for public email providers" do
      spain = country("Spain", "ESP", "spain")
      organization = create_organization("Public Inbox Collective", [spain])
      add_member(organization, "someone@gmail.com", name: "Gmail Person")

      %w[gmail.com outlook.com hotmail.com yahoo.com].each do |domain|
        user = create(:user, email: "person@#{domain}", name: "Public User")
        add_member(organization, "member@#{domain}", name: "Public Member") unless domain == "gmail.com"

        get "/api/v2/organizations/suggested", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(response_json).to eq([])
      end

      cased = create(:user, email: "cased.person@gmail.com", name: "Cased Public")
      cased.update_column(:email, "cased.person@Gmail.COM")

      get "/api/v2/organizations/suggested", headers: auth_headers(cased)

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq([])
    end

    it "caps results at five, ordered by matching members then name" do
      user = create(:user, email: "ana@wetlands.org", name: "Ana Wetlands")
      spain = country("Spain", "ESP", "spain")
      own = create_organization("Own Org", [spain], user: user, role: "org-user")
      4.times { |index| add_member(own, "own#{index}@wetlands.org") }

      zeta = create_organization("zeta trust", [spain])
      3.times { |index| add_member(zeta, "zeta#{index}@wetlands.org") }
      delta = create_organization("Delta Coast", [spain])
      2.times { |index| add_member(delta, "delta#{index}@wetlands.org") }
      %w[alpha Beta Epsilon Eta Gamma].each do |name|
        organization = create_organization(name, [spain])
        add_member(organization, "#{name.downcase}@wetlands.org")
      end
      mixed = create_organization("Mixed", [spain])
      add_member(mixed, "one@wetlands.org")
      5.times { |index| add_member(mixed, "mixed#{index}@gmail.com") }

      get "/api/v2/organizations/suggested", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json.pluck("organization_name")).to eq([
        "zeta trust",
        "Delta Coast",
        "alpha",
        "Beta",
        "Epsilon"
      ])
      expect(response.body).not_to include("@wetlands.org")
      expect(response.body).not_to include("@gmail.com")
    end

    it "is not available on v3" do
      user = create(:user, email: "ana@wetlands.org")
      spain = country("Spain", "ESP", "spain")
      organization = create_organization("Mangrove Watch", [spain])
      add_member(organization, "bob@wetlands.org")

      get "/api/v3/organizations/suggested", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  def create_organization(name, countries, user: nil, role: nil)
    organization = Organization.create!(
      organization_name: name,
      country_location_ids: countries.map(&:location_id)
    )
    OrganizationsUsers.create!(organization: organization, user: user, role: role) if user
    organization
  end

  def add_member(organization, email, name: "Member")
    member = create(:user, email: email, name: name)
    OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
    member
  end

  def organization_names
    response_json["data"].pluck("organization_name")
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

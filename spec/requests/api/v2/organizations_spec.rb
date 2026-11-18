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
        params: {organization_name: "", country_location_ids: [], admin_name_acknowledged: true},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["organization_name"]).to include("can't be blank")
      expect(response_json["errors"]["country_location_ids"]).to include("must include at least one country")
      expect(Organization.count).to eq(0)

      post "/api/v2/organizations",
        params: {organization_name: "Coastal Alliance", admin_name_acknowledged: true},
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
        params: {organization_name: "Coastal Alliance", country_location_ids: [area.location_id], admin_name_acknowledged: true},
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
        country_location_ids: [kenya.location_id, spain.location_id],
        admin_name_acknowledged: true
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
      OrganizationsUsers.create!(
        organization: organization,
        user: user,
        role: "org-admin",
        admin_name_acknowledged_at: Time.current
      )

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
          country_location_ids: [kenya.location_id, spain.location_id],
          admin_name_acknowledged: true
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

  describe "admin name acknowledgement" do
    it "returns 422 and creates nothing without the creator's acknowledgement" do
      user = create(:user, name: "Ada Admin", email: "ada@wetlands.org")
      spain = country("Spain", "ESP", "spain")

      expect {
        post "/api/v2/organizations",
          params: {organization_name: "Unacknowledged Coast", country_location_ids: [spain.location_id]},
          headers: auth_headers(user),
          as: :json
      }.not_to change { [Organization.count, OrganizationsUsers.count] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")

      expect {
        post "/api/v2/organizations",
          params: {
            organization_name: "Unacknowledged Coast",
            country_location_ids: [spain.location_id],
            admin_name_acknowledged: false
          },
          headers: auth_headers(user),
          as: :json
      }.not_to change { [Organization.count, OrganizationsUsers.count] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Organization.find_by(organization_name: "Unacknowledged Coast")).to be_nil
    end

    it "lists acknowledged admin names to non-members and omits contact details" do
      creator = create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
      spain = country("Spain", "ESP", "spain")

      post "/api/v2/organizations",
        params: {
          organization_name: "Named Admins",
          country_location_ids: [spain.location_id],
          admin_name_acknowledged: true
        },
        headers: auth_headers(creator),
        as: :json

      organization = Organization.find(response_json["id"])
      expect(OrganizationsUsers.find_by!(organization: organization, user: creator).admin_name_acknowledged_at).to be_present

      second = create(:user, name: "Bea Admin", email: "bea.admin@wetlands.org")
      OrganizationsUsers.create!(organization: organization, user: second, role: "org-user")
      hidden = create(:user, name: "Zed Hidden", email: "zed.hidden@wetlands.org")
      OrganizationsUsers.create!(organization: organization, user: hidden, role: "org-admin")

      patch "/api/v2/organizations/#{organization.id}/users/#{second.email}",
        params: {role: "org-admin", admin_name_acknowledged: true},
        headers: auth_headers(creator),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(OrganizationsUsers.find_by!(organization: organization, user: second).role).to eq("org-admin")

      outsider = create(:user, name: "Outsider", email: "outsider@example.com")

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:ok)
      expect(response_json["admins"]).to eq([{"name" => "Ada Admin"}, {"name" => "Bea Admin"}])
      expect(response_json["admins"].flat_map(&:keys).uniq).to eq(["name"])
      expect(response.body).not_to include("ada.admin@wetlands.org")
      expect(response.body).not_to include("bea.admin@wetlands.org")
      expect(response.body).not_to include("zed.hidden@wetlands.org")
      expect(response.body).not_to include("Zed Hidden")

      get "/api/v2/organizations", headers: auth_headers(outsider)

      expect(response.body).not_to include("ada.admin@wetlands.org")
      expect(response.body).not_to include("bea.admin@wetlands.org")
      expect(response.body).not_to include("zed.hidden@wetlands.org")
    end

    it "rejects promotion to admin without acknowledgement and leaves the member as org-user" do
      spain = country("Spain", "ESP", "spain")
      admin = create(:user, name: "Ada Admin", email: "ada.admin@wetlands.org")
      member = create(:user, name: "Mia Member", email: "mia.member@wetlands.org")
      organization = create_organization("Promotion Org", [spain], user: admin, role: "org-admin", admin_name_acknowledged_at: Time.current)
      membership = OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      patch "/api/v2/organizations/#{organization.id}/users/#{member.email}",
        params: {role: "org-admin"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(membership.reload.role).to eq("org-user")
      expect(membership.admin_name_acknowledged_at).to be_nil

      patch "/api/v2/organizations/#{organization.id}/users/#{member.email}",
        params: {role: "org-admin", admin_name_acknowledged: false},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(membership.reload.role).to eq("org-user")

      post "/api/v2/organizations/#{organization.id}/users",
        params: {email: member.email, role: "org-admin"},
        headers: auth_headers(admin),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(membership.reload.role).to eq("org-user")
    end

    it "asks an existing admin to acknowledge, blocks admin actions until they do, and demotes them if they decline" do
      spain = country("Spain", "ESP", "spain")
      legacy = create(:user, name: "Pat Manager", email: "legacy.admin@wetlands.org")
      organization = create_organization("Legacy Admins", [spain], user: legacy, role: "org-admin")
      landscape = Landscape.create!(landscape_name: "Legacy Delta")
      LandscapesOrganizations.create!(landscape_id: landscape.id, organization_id: organization.id)
      outsider = create(:user, email: "outsider.legacy@example.com")

      get "/users/current_user", headers: auth_headers(legacy)

      expect(response_json["user"]["pending_admin_name_acknowledgements"]).to eq([
        {"organization_id" => organization.id, "organization_name" => "Legacy Admins"}
      ])

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response_json["admins"]).to eq([])
      expect(response.body).not_to include("legacy.admin@wetlands.org")
      expect(response.body).not_to include("Pat Manager")

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Renamed Without Acknowledgement", country_location_ids: [spain.location_id]},
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(organization.reload.organization_name).to eq("Legacy Admins")

      delete "/api/v2/landscapes/#{landscape.id}", headers: auth_headers(legacy)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Landscape.exists?(landscape.id)).to be(true)

      post "/api/v2/organizations/#{organization.id}/admin_name_acknowledgement",
        params: {admin_name_acknowledged: false},
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["admins"]).to eq([])
      membership = OrganizationsUsers.find_by!(organization: organization, user: legacy)
      expect(membership.role).to eq("org-user")
      expect(membership.admin_name_acknowledged_at).to be_nil

      get "/users/current_user", headers: auth_headers(legacy)

      expect(response_json["user"]["pending_admin_name_acknowledgements"]).to eq([])

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Still Not Admin", country_location_ids: [spain.location_id]},
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:forbidden)
      expect(organization.reload.organization_name).to eq("Legacy Admins")
    end

    it "shows an existing admin's name after they acknowledge and then allows admin actions" do
      spain = country("Spain", "ESP", "spain")
      legacy = create(:user, name: "Pat Manager", email: "legacy.admin@wetlands.org")
      organization = create_organization("Legacy Admins", [spain], user: legacy, role: "org-admin")
      outsider = create(:user, email: "outsider.ack@example.com")

      post "/api/v2/organizations/#{organization.id}/admin_name_acknowledgement",
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(OrganizationsUsers.find_by!(organization: organization, user: legacy).admin_name_acknowledged_at).to be_nil

      post "/api/v2/organizations/#{organization.id}/admin_name_acknowledgement",
        params: {admin_name_acknowledged: true},
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["admins"]).to eq([{"name" => "Pat Manager"}])
      expect(response.body).not_to include("legacy.admin@wetlands.org")
      expect(OrganizationsUsers.find_by!(organization: organization, user: legacy).admin_name_acknowledged_at).to be_present

      get "/api/v2/organizations/#{organization.id}", headers: auth_headers(outsider)

      expect(response_json["admins"]).to eq([{"name" => "Pat Manager"}])
      expect(response.body).not_to include("legacy.admin@wetlands.org")

      get "/users/current_user", headers: auth_headers(legacy)

      expect(response_json["user"]["pending_admin_name_acknowledgements"]).to eq([])

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Acknowledged Coast", country_location_ids: [spain.location_id]},
        headers: auth_headers(legacy),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(organization.reload.organization_name).to eq("Acknowledged Coast")
    end

    it "lets a platform admin manage an organization without an acknowledgement" do
      spain = country("Spain", "ESP", "spain")
      staff = create(:user, admin: true, name: "Platform Admin", email: "platform.admin@wetlands.org")
      organization = create_organization("Staff Managed", [spain])

      patch "/api/v2/organizations/#{organization.id}",
        params: {organization_name: "Staff Renamed", country_location_ids: [spain.location_id]},
        headers: auth_headers(staff),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(organization.reload.organization_name).to eq("Staff Renamed")
    end

    it "does not change v3 organization create, promotion, admin actions, or the show payload" do
      user = create(:user, name: "V3 Admin", email: "v3.admin@wetlands.org")
      member = create(:user, name: "V3 Member", email: "v3.member@wetlands.org")
      spain = country("Spain", "ESP", "spain-v3")

      post "/api/v3/organizations",
        params: {organization_name: "V3 Coast", country_location_ids: [spain.location_id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_key("admins")
      organization = Organization.find(response_json["id"])
      membership = OrganizationsUsers.find_by!(organization: organization, user: user)
      expect(membership.role).to eq("org-admin")
      expect(membership.admin_name_acknowledged_at).to be_nil

      get "/api/v3/organizations/#{organization.id}", headers: auth_headers(member)

      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_key("admins")
      expect(response.body).not_to include("v3.admin@wetlands.org")
      expect(response.body).not_to include("V3 Admin")

      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      patch "/api/v3/organizations/#{organization.id}/users/#{member.email}",
        params: {role: "org-admin"},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      promoted = OrganizationsUsers.find_by!(organization: organization, user: member)
      expect(promoted.role).to eq("org-admin")
      expect(promoted.admin_name_acknowledged_at).to be_nil

      patch "/api/v3/organizations/#{organization.id}",
        params: {organization_name: "V3 Coast renamed", country_location_ids: [spain.location_id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(organization.reload.organization_name).to eq("V3 Coast renamed")

      expect {
        post "/api/v3/organizations/#{organization.id}/admin_name_acknowledgement",
          params: {admin_name_acknowledged: true},
          headers: auth_headers(user),
          as: :json
      }.to raise_error(ActionController::RoutingError)
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

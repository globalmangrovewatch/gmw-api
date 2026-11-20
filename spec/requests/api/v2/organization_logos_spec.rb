require "rails_helper"

RSpec.describe "Organization logos", type: :request do
  def png_bytes
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
  end

  def jpeg_bytes
    "\xFF\xD8\xFF\xD9".b
  end

  def upload(bytes, filename:, content_type:)
    file = Tempfile.new(["logo", File.extname(filename)])
    file.binmode
    file.write(bytes)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end

  def png_upload
    upload(png_bytes, filename: "mark.png", content_type: "image/png")
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end

  def country
    Location.create!(
      name: "Spain",
      location_type: "country",
      iso: "ESP",
      location_id: "spain-#{SecureRandom.hex(4)}",
      bounds: {},
      geometry: {}
    )
  end

  def organization_for(user, role: "org-admin", acknowledged: true)
    organization = Organization.create!(
      organization_name: "Mangrove Partnership #{SecureRandom.hex(4)}",
      country_location_ids: [country.location_id]
    )
    OrganizationsUsers.create!(
      organization: organization,
      user: user,
      role: role,
      admin_name_acknowledged_at: (Time.current if acknowledged && role == "org-admin")
    )
    organization
  end

  def follow_all_redirects!
    5.times do
      break unless response.redirect?
      follow_redirect!
    end
  end

  describe "POST /api/v2/organizations" do
    it "stores a logo for the creator and returns logo_url" do
      user = create(:user, name: "Ada Admin")
      spain = country

      post "/api/v2/organizations",
        params: {
          organization_name: "Logo Coast",
          country_location_ids: [spain.location_id],
          admin_name_acknowledged: true,
          logo: png_upload
        },
        headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      organization = Organization.find(response_json["id"])
      expect(organization.logo).to be_attached
      expect(organization.logo.blob.content_type).to eq("image/png")
      expect(organization.logo.download).to eq(png_bytes)
      expect(response_json["logo_url"]).to include("/rails/active_storage/blobs/redirect/")

      get response_json["logo_url"]
      follow_all_redirects!
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("image/png")
      expect(response.body).to eq(png_bytes)
    end

    it "returns field errors and creates nothing when the logo is invalid" do
      user = create(:user)

      expect {
        post "/api/v2/organizations",
          params: {
            organization_name: "",
            country_location_ids: [],
            admin_name_acknowledged: false,
            logo: upload("notes", filename: "notes.txt", content_type: "text/plain")
          },
          headers: auth_headers(user)
      }.not_to change(Organization, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["organization_name"]).to include("can't be blank")
      expect(response_json["errors"]["country_location_ids"]).to include("must include at least one country")
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(response_json["errors"]["logo"]).to include("must be a PNG, JPEG, WebP, or SVG")
      expect(ActiveStorage::Blob.count).to eq(0)
    end
  end

  describe "PUT /api/v2/organizations/:id/logo" do
    it "lets an acknowledged org admin replace the logo" do
      admin = create(:user, name: "Ada Admin")
      organization = organization_for(admin)
      organization.attach_logo(png_upload)
      first_blob_id = organization.logo.blob.id

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: upload(jpeg_bytes, filename: "mark.jpg", content_type: "image/jpeg")},
        headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(response_json["logo_url"]).to be_present
      organization.reload
      expect(organization.logo.blob.id).not_to eq(first_blob_id)
      expect(organization.logo.blob.content_type).to eq("image/jpeg")
      expect(organization.logo.download).to eq(jpeg_bytes)
    end

    it "stores SVG only after removing active content" do
      admin = create(:user)
      organization = organization_for(admin)
      svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" onload="alert(1)">
          <script>alert(1)</script>
          <rect width="4" height="4" fill="green"/>
        </svg>
      SVG

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: upload(svg, filename: "mark.svg", content_type: "image/svg+xml")},
        headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      stored = organization.reload.logo.download
      expect(organization.logo.blob.content_type).to eq("image/svg+xml")
      expect(stored).to include("<rect")
      expect(stored).not_to include("script")
      expect(stored).not_to include("onload")

      get response_json["logo_url"]
      follow_all_redirects!
      expect(response.media_type).to eq("image/svg+xml")
    end

    it "rejects a file over 2 MB or a file that is not an allowed image" do
      admin = create(:user)
      organization = organization_for(admin)
      organization.attach_logo(png_upload)

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: upload("a" * (OrganizationLogo::MAX_BYTES + 1), filename: "big.png", content_type: "image/png")},
        headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["logo"]).to include("must be 2 MB or smaller")
      expect(organization.reload.logo.blob.content_type).to eq("image/png")

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: upload("GIF89a", filename: "mark.gif", content_type: "image/gif")},
        headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["logo"]).to include("must be a PNG, JPEG, WebP, or SVG")
      expect(organization.reload.logo.download).to eq(png_bytes)

      put "/api/v2/organizations/#{organization.id}/logo", headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["logo"]).to include("can't be blank")
    end

    it "rejects members, unacknowledged admins, and anonymous users" do
      admin = create(:user, name: "Ada Admin")
      member = create(:user, name: "Member")
      outsider = create(:user)
      organization = organization_for(admin)
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
      unacknowledged = create(:user)
      OrganizationsUsers.create!(organization: organization, user: unacknowledged, role: "org-admin")

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: png_upload},
        headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
      expect(organization.reload.logo).not_to be_attached

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: png_upload},
        headers: auth_headers(outsider)

      expect(response).to have_http_status(:forbidden)

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: png_upload},
        headers: auth_headers(unacknowledged)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["admin_name_acknowledged"]).to include("must be accepted")
      expect(organization.reload.logo).not_to be_attached

      put "/api/v2/organizations/#{organization.id}/logo", params: {logo: png_upload}

      expect(response).to have_http_status(:unauthorized)
    end

    it "lets a platform admin upload without an acknowledgement" do
      staff = create(:user, admin: true)
      organization = Organization.create!(
        organization_name: "Staff Org #{SecureRandom.hex(4)}",
        country_location_ids: [country.location_id]
      )

      put "/api/v2/organizations/#{organization.id}/logo",
        params: {logo: png_upload},
        headers: auth_headers(staff)

      expect(response).to have_http_status(:ok)
      expect(organization.reload.logo).to be_attached
    end
  end

  describe "DELETE /api/v2/organizations/:id/logo" do
    it "removes the logo for an org admin and leaves logo_url empty" do
      admin = create(:user)
      organization = organization_for(admin)
      organization.attach_logo(png_upload)

      delete "/api/v2/organizations/#{organization.id}/logo", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(response_json["logo_url"]).to be_nil
      expect(organization.reload.logo).not_to be_attached
    end

    it "does not let a member remove the logo" do
      admin = create(:user)
      member = create(:user)
      organization = organization_for(admin)
      organization.attach_logo(png_upload)
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")

      delete "/api/v2/organizations/#{organization.id}/logo", headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
      expect(organization.reload.logo).to be_attached
    end
  end

  describe "organization responses" do
    it "returns logo_url from the list and the detail" do
      user = create(:user)
      with_logo = organization_for(user)
      with_logo.attach_logo(png_upload)
      without_logo = Organization.create!(
        organization_name: "Plain Coast #{SecureRandom.hex(4)}",
        country_location_ids: [country.location_id]
      )

      get "/api/v2/organizations/#{with_logo.id}", headers: auth_headers(user)
      expect(response_json["logo_url"]).to include("/rails/active_storage/")

      get "/api/v2/organizations/#{without_logo.id}", headers: auth_headers(user)
      expect(response_json["logo_url"]).to be_nil

      get "/api/v2/organizations", headers: auth_headers(user)
      listed = response_json["data"].index_by { |organization| organization["id"] }
      expect(listed[with_logo.id]["logo_url"]).to include("/rails/active_storage/")
      expect(listed[without_logo.id]["logo_url"]).to be_nil
    end
  end

  describe "v3" do
    it "does not add logo routes or logo_url" do
      user = create(:user, name: "V3 Admin")
      spain = country
      organization = organization_for(user)
      organization.attach_logo(png_upload)

      get "/api/v3/organizations/#{organization.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_key("logo_url")

      get "/api/v3/organizations", headers: auth_headers(user)
      listed = response_json.find { |item| item["id"] == organization.id }
      expect(listed).not_to have_key("logo_url")

      post "/api/v3/organizations",
        params: {
          organization_name: "V3 Coast",
          country_location_ids: [spain.location_id],
          logo: png_upload
        },
        headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_key("logo_url")
      expect(Organization.find(response_json["id"]).logo).not_to be_attached

      expect {
        put "/api/v3/organizations/#{organization.id}/logo",
          params: {logo: png_upload},
          headers: auth_headers(user)
      }.to raise_error(ActionController::RoutingError)

      expect {
        delete "/api/v3/organizations/#{organization.id}/logo", headers: auth_headers(user)
      }.to raise_error(ActionController::RoutingError)
    end
  end
end

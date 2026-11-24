require "rails_helper"

RSpec.describe "Landscapes", type: :request do
  describe "POST /api/v2/landscapes" do
    it "links organizations the user belongs to" do
      user = create(:user)
      organization = create(:organization)
      OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

      post "/api/v2/landscapes",
        params: {landscape: {landscape_name: "River delta"}, organizations: [organization.id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      landscape = Landscape.find(response_json["id"])
      expect(landscape.organization_ids).to eq([organization.id])
    end

    it "requires an invitation for an organization the user does not belong to" do
      user = create(:user)
      own = create(:organization)
      other = create(:organization)
      OrganizationsUsers.create!(organization: own, user: user, role: "org-user")

      expect {
        post "/api/v2/landscapes",
          params: {landscape: {landscape_name: "River delta"}, organizations: [own.id, other.id]},
          headers: auth_headers(user),
          as: :json
      }.not_to change(Landscape, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["organizations"]).to include("must be invited")
    end

    it "still lets a platform admin link an organization they do not belong to" do
      staff = create(:user, admin: true)
      organization = create(:organization)

      post "/api/v2/landscapes",
        params: {landscape: {landscape_name: "River delta"}, organizations: [organization.id]},
        headers: auth_headers(staff),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(Landscape.find(response_json["id"]).organization_ids).to eq([organization.id])
    end
  end

  describe "PATCH /api/v2/landscapes/:id" do
    it "keeps organizations the user does not belong to while replacing their own" do
      user = create(:user)
      own = create(:organization)
      other_own = create(:organization)
      partner = create(:organization)
      OrganizationsUsers.create!(organization: own, user: user, role: "org-user")
      OrganizationsUsers.create!(organization: other_own, user: user, role: "org-user")
      landscape = create(:landscape, landscape_name: "Old name")
      LandscapesOrganizations.create!(landscape: landscape, organization: own)
      LandscapesOrganizations.create!(landscape: landscape, organization: partner)

      patch "/api/v2/landscapes/#{landscape.id}",
        params: {landscape: {landscape_name: "New name"}, organizations: [other_own.id, partner.id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(landscape.reload.landscape_name).to eq("New name")
      expect(landscape.organization_ids).to contain_exactly(other_own.id, partner.id)
    end

    it "rejects a new organization the user does not belong to without changing the landscape" do
      user = create(:user)
      own = create(:organization)
      other = create(:organization)
      OrganizationsUsers.create!(organization: own, user: user, role: "org-user")
      landscape = create(:landscape, landscape_name: "Old name")
      LandscapesOrganizations.create!(landscape: landscape, organization: own)

      patch "/api/v2/landscapes/#{landscape.id}",
        params: {landscape: {landscape_name: "New name"}, organizations: [own.id, other.id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["errors"]["organizations"]).to include("must be invited")
      expect(landscape.reload.landscape_name).to eq("Old name")
      expect(landscape.organization_ids).to eq([own.id])
    end

    it "lets a platform admin replace the organization list" do
      staff = create(:user, admin: true)
      kept = create(:organization)
      removed = create(:organization)
      added = create(:organization)
      landscape = create(:landscape, landscape_name: "Old name")
      LandscapesOrganizations.create!(landscape: landscape, organization: kept)
      LandscapesOrganizations.create!(landscape: landscape, organization: removed)

      patch "/api/v2/landscapes/#{landscape.id}",
        params: {landscape: {landscape_name: "New name"}, organizations: [kept.id, added.id]},
        headers: auth_headers(staff),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(landscape.reload.organization_ids).to contain_exactly(kept.id, added.id)
    end
  end

  describe "api v3 landscapes" do
    it "still replaces every organization link when a member updates the landscape" do
      user = create(:user)
      own = create(:organization)
      partner = create(:organization)
      OrganizationsUsers.create!(organization: own, user: user, role: "org-user")
      landscape = create(:landscape, landscape_name: "Old name")
      LandscapesOrganizations.create!(landscape: landscape, organization: own)
      LandscapesOrganizations.create!(landscape: landscape, organization: partner)

      patch "/api/v3/landscapes/#{landscape.id}",
        params: {landscape: {landscape_name: "New name"}, organizations: [own.id]},
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(landscape.reload.landscape_name).to eq("New name")
      expect(landscape.organization_ids).to eq([own.id])
    end

    it "still rejects a member who is not part of every submitted organization" do
      user = create(:user)
      own = create(:organization)
      other = create(:organization)
      OrganizationsUsers.create!(organization: own, user: user, role: "org-user")

      expect {
        post "/api/v3/landscapes",
          params: {landscape: {landscape_name: "River delta"}, organizations: [own.id, other.id]},
          headers: auth_headers(user),
          as: :json
      }.not_to change(Landscape, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end
end

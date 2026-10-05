require "rails_helper"

RSpec.describe "Admin organization memberships", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123", role: :super_admin) }
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  before do
    sign_in admin_user
  end

  it "shows the appropriate role action for each member" do
    membership = OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

    get admin_organization_path(organization)

    expect(response.body).to include("Make admin")

    membership.update!(role: "org-admin")
    get admin_organization_path(organization)

    expect(response.body).to include("Remove admin")
  end

  it "promotes an organization member to admin" do
    membership = OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

    post promote_member_admin_organization_path(organization), params: {user_id: user.id}

    expect(response).to redirect_to(admin_organization_path(organization))
    expect(membership.reload.role).to eq("org-admin")
  end

  it "removes organization admin access without removing membership" do
    membership = OrganizationsUsers.create!(organization: organization, user: user, role: "org-admin")

    post demote_member_admin_organization_path(organization), params: {user_id: user.id}

    expect(response).to redirect_to(admin_organization_path(organization))
    expect(membership.reload.role).to eq("org-user")
    expect(organization.reload.users).to include(user)
  end

  context "when signed in as staff" do
    let(:admin_user) { AdminUser.create!(email: "staff@example.com", password: "password123", role: :staff) }

    it "retains access to the back office" do
      get admin_users_path

      expect(response).to have_http_status(:ok)
    end

    it "does not allow access to back-office account management" do
      get admin_admin_users_path

      expect(response).to redirect_to(admin_root_path)
    end

    it "does not show organization role actions" do
      OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

      get admin_organization_path(organization)

      expect(response.body).not_to include("Make admin")
      expect(response.body).not_to include("Remove admin")
    end

    it "does not allow a member to be promoted directly" do
      membership = OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

      post promote_member_admin_organization_path(organization), params: {user_id: user.id}

      expect(response).to redirect_to(admin_root_path)
      expect(membership.reload.role).to eq("org-user")
    end

    it "does not allow a membership role to be updated directly" do
      membership = OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

      patch admin_organizations_user_path(membership), params: {
        organizations_users: {role: "org-admin"}
      }

      expect(response).to redirect_to(admin_root_path)
      expect(membership.reload.role).to eq("org-user")
    end

    it "does not allow a user's global admin flag to be updated" do
      patch admin_user_path(user), params: {
        user: {admin: true, password: "", password_confirmation: ""}
      }

      expect(response).to redirect_to(admin_user_path(user))
      expect(user.reload.admin).to be(false)
    end
  end
end

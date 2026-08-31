require "rails_helper"

RSpec.describe "Admin organization memberships", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }
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
end

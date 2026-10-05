require "rails_helper"

RSpec.describe AdminUser, type: :model do
  it "defaults new back-office accounts to staff" do
    admin_user = AdminUser.create!(email: "staff@example.com", password: "password123")

    expect(admin_user).to be_staff
  end

  it "supports super admin accounts" do
    admin_user = AdminUser.create!(email: "super-admin@example.com", password: "password123", role: :super_admin)

    expect(admin_user).to be_super_admin
  end

  it "does not allow the last super admin to be demoted" do
    admin_user = AdminUser.create!(email: "super-admin@example.com", password: "password123", role: :super_admin)

    expect(admin_user.update(role: :staff)).to be(false)
    expect(admin_user.reload).to be_super_admin
  end

  it "allows a super admin to be demoted when another remains" do
    admin_user = AdminUser.create!(email: "super-admin@example.com", password: "password123", role: :super_admin)
    AdminUser.create!(email: "other-super-admin@example.com", password: "password123", role: :super_admin)

    expect(admin_user.update(role: :staff)).to be(true)
    expect(admin_user).to be_staff
  end

  it "does not allow the last super admin to be deleted" do
    admin_user = AdminUser.create!(email: "super-admin@example.com", password: "password123", role: :super_admin)

    admin_user.destroy

    expect(admin_user).not_to be_destroyed
    expect(AdminUser.exists?(admin_user.id)).to be(true)
  end
end

require "rails_helper"

RSpec.describe User, type: :model do
  describe "user_roles validations" do
    it "accepts valid roles" do
      user = build(:user, user_roles: ["scientist", "ngo"])

      expect(user).to be_valid
    end

    it "rejects invalid roles" do
      user = build(:user, user_roles: ["invalid_role"])

      expect(user).not_to be_valid
      expect(user.errors[:user_roles]).to include("contains invalid values: invalid_role")
    end

    it "requires user_role_other when other is selected" do
      user = build(:user, user_roles: ["other"], user_role_other: nil)

      expect(user).not_to be_valid
      expect(user.errors[:user_role_other]).to include("can't be blank when other is selected")
    end

    it "persists user_role_other when other is selected" do
      user = build(:user, user_roles: ["scientist", "other"], user_role_other: "Marine consultant")

      expect(user).to be_valid
    end

    it "clears user_role_other when other is not selected" do
      user = build(:user, user_roles: ["scientist"], user_role_other: "Should be cleared")

      user.valid?

      expect(user.user_role_other).to be_nil
    end

    it "allows existing users with empty roles" do
      user = create(:user, user_roles: [])

      expect(user).to be_persisted
      expect(user.reload.user_roles).to eq([])
      expect(user.user_role_other).to be_nil
    end

    it "deduplicates roles" do
      user = build(:user, user_roles: ["scientist", "scientist"])

      user.valid?

      expect(user.user_roles).to eq(["scientist"])
    end
  end

  describe "#profile_attributes" do
    it "returns profile fields including user roles" do
      user = build(
        :user,
        name: "Jane Doe",
        email: "jane@example.com",
        organization_name: "Example Org",
        user_roles: ["other"],
        user_role_other: "Independent consultant"
      )

      expect(user.profile_attributes).to eq(
        name: "Jane Doe",
        email: "jane@example.com",
        organization: "Example Org",
        user_roles: ["other"],
        user_role_other: "Independent consultant"
      )
    end
  end

  describe "organization" do
    it "stores organization via organization=" do
      user = build(:user, organization: "Profile Org")

      expect(user.organization_name).to eq("Profile Org")
      expect(user.organization).to eq("Profile Org")
    end

    it "falls back to linked organization when profile organization is blank" do
      user = create(:user, organization_name: nil)
      org = create(:organization, organization_name: "Linked Org")
      OrganizationsUsers.create!(user: user, organization: org, role: "org-user")

      expect(user.organization).to eq("Linked Org")
    end
  end
end

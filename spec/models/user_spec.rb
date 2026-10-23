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
        user_role_other: "Independent consultant",
        settings: nil
      )
    end
  end

  describe "settings" do
    let(:valid_settings) do
      {
        "basemap" => "light",
        "bounds" => [[-180, -60], [180, 60]],
        "widgets" => ["mangrove_habitat_extent", "mangrove_net_change"],
        "layers" => [{"id" => "mangrove_habitat_extent", "opacity" => 0.8}]
      }
    end

    it "allows a null map configuration" do
      user = build(:user, settings: nil)

      expect(user).to be_valid
    end

    it "accepts a valid map configuration" do
      user = build(:user, settings: valid_settings)

      expect(user).to be_valid
    end

    it "sets saved_at when settings are written and ignores a client value" do
      user = create(:user, settings: valid_settings.merge("saved_at" => "2000-01-01T00:00:00Z"))

      expect(user.settings["saved_at"]).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/)
      expect(user.settings["saved_at"]).not_to eq("2000-01-01T00:00:00Z")
      expect(user.settings["basemap"]).to eq("light")
    end

    it "leaves saved_at unchanged when settings are not updated" do
      user = create(:user, settings: valid_settings)
      saved_at = user.settings["saved_at"]

      user.update!(name: "Updated name")

      expect(user.reload.settings["saved_at"]).to eq(saved_at)
    end

    it "rejects an unknown basemap" do
      user = build(:user, settings: valid_settings.merge("basemap" => "terrain"))

      expect(user).not_to be_valid
      expect(user.errors[:settings]).to include("basemap must be one of: light, dark, satellite")
    end

    it "rejects bounds that are not [[west, south], [east, north]]" do
      user = build(:user, settings: valid_settings.merge("bounds" => [[-200, -60], [180, 60]]))

      expect(user).not_to be_valid
      expect(user.errors[:settings]).to include("bounds must be [[west, south], [east, north]]")
    end

    it "rejects layer opacity outside 0..1" do
      user = build(:user, settings: valid_settings.merge("layers" => [{"id" => "mangrove_habitat_extent", "opacity" => 1.2}]))

      expect(user).not_to be_valid
      expect(user.errors[:settings]).to include("layers opacity must be a number between 0 and 1")
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

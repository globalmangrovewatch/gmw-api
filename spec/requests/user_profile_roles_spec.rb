require "rails_helper"

RSpec.describe "User profile roles", type: :request do
  before do
    ActionMailer::Base.default_url_options[:host] = "example.com"
  end

  describe "GET /users/current_user" do
    it "returns saved user roles" do
      user = create(
        :user,
        user_roles: ["government_policy", "other"],
        user_role_other: "Policy advisor"
      )

      get "/users/current_user", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "name" => user.name,
        "email" => user.email,
        "user_roles" => ["government_policy", "other"],
        "user_role_other" => "Policy advisor"
      )
    end

    it "returns empty roles for legacy users" do
      user = create(:user, user_roles: [])

      get "/users/current_user", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["user_roles"]).to eq([])
      expect(response_json["user"]["user_role_other"]).to be_nil
      expect(response_json["user"]["settings"]).to be_nil
    end

    it "returns saved map settings" do
      settings = {
        "basemap" => "satellite",
        "bounds" => [[-10, -5], [10, 5]],
        "widgets" => ["mangrove_net_change"],
        "layers" => [{"id" => "mangrove_net_change", "opacity" => 1}]
      }
      user = create(:user, settings: settings)

      get "/users/current_user", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["settings"]).to eq(settings)
    end
  end

  describe "POST /users" do
    it "persists organization on signup" do
      post "/users", params: {
        user: {
          email: "orguser@example.com",
          password: "password123",
          name: "Org User",
          organization: "Coastal Conservation Alliance"
        }
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["organization"]).to eq("Coastal Conservation Alliance")

      created_user = User.find_by(email: "orguser@example.com")
      expect(created_user.organization_name).to eq("Coastal Conservation Alliance")
    end

    it "creates a user with multiple roles and other value" do
      post "/users", params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          name: "New User",
          user_roles: ["scientist", "other"],
          user_role_other: "Field technician"
        }
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "email" => "newuser@example.com",
        "name" => "New User",
        "user_roles" => ["scientist", "other"],
        "user_role_other" => "Field technician"
      )

      created_user = User.find_by(email: "newuser@example.com")
      expect(created_user.user_roles).to eq(["scientist", "other"])
      expect(created_user.user_role_other).to eq("Field technician")
    end

    it "rejects signup when other is selected without a custom value" do
      post "/users", params: {
        user: {
          email: "invalid@example.com",
          password: "password123",
          name: "Invalid User",
          user_roles: ["other"]
        }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["message"]).to include("User role other can't be blank when other is selected")
    end
  end

  describe "PATCH /users" do
    it "updates organization on profile update" do
      user = create(:user, organization_name: "Old Org")

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          organization: "New Org"
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["organization"]).to eq("New Org")

      user.reload
      expect(user.organization_name).to eq("New Org")
    end

    it "updates user roles on profile update" do
      user = create(:user, user_roles: ["ngo"])

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          user_roles: ["industry", "other"],
          user_role_other: "Consultant"
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "user_roles" => ["industry", "other"],
        "user_role_other" => "Consultant"
      )

      user.reload
      expect(user.user_roles).to eq(["industry", "other"])
      expect(user.user_role_other).to eq("Consultant")
    end

    it "clears user_role_other when other is removed" do
      user = create(
        :user,
        user_roles: ["other"],
        user_role_other: "Old value"
      )

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          user_roles: ["education"]
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "user_roles" => ["education"],
        "user_role_other" => nil
      )
    end

    it "saves map settings" do
      user = create(:user)
      settings = {
        "basemap" => "dark",
        "bounds" => [[-180, -60], [180, 60]],
        "widgets" => ["mangrove_habitat_extent"],
        "layers" => [{"id" => "mangrove_habitat_extent", "opacity" => 0.8}]
      }

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          settings: settings
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["settings"]).to eq(settings)
      expect(user.reload.settings).to eq(settings)
    end

    it "clears map settings when null is sent" do
      user = create(:user, settings: {"basemap" => "light"})

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          settings: nil
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["settings"]).to be_nil
      expect(user.reload.settings).to be_nil
    end

    it "rejects invalid map settings" do
      user = create(:user)

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          settings: {"basemap" => "terrain", "layers" => [{"id" => "mangrove_habitat_extent", "opacity" => 2}]}
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json["message"]).to include("basemap must be one of: light, dark, satellite")
      expect(response_json["message"]).to include("layers opacity must be a number between 0 and 1")
    end
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end
end

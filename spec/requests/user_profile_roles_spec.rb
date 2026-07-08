require "rails_helper"

RSpec.describe "User profile roles", type: :request do
  before do
    ActionMailer::Base.default_url_options[:host] = "example.com"
  end

  describe "GET /users/current_user" do
    it "returns saved user roles" do
      user = create(
        :user,
        user_roles: ["government", "other"],
        user_role_other: "Policy advisor"
      )

      get "/users/current_user", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "name" => user.name,
        "email" => user.email,
        "user_roles" => ["government", "other"],
        "user_role_other" => "Policy advisor"
      )
    end

    it "returns empty roles for legacy users" do
      user = create(:user, user_roles: [])

      get "/users/current_user", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]["user_roles"]).to eq([])
      expect(response_json["user"]["user_role_other"]).to be_nil
    end
  end

  describe "POST /users" do
    it "creates a user with multiple roles and other value" do
      post "/users", params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          name: "New User",
          user_roles: ["researcher", "other"],
          user_role_other: "Field technician"
        }
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "email" => "newuser@example.com",
        "name" => "New User",
        "user_roles" => ["researcher", "other"],
        "user_role_other" => "Field technician"
      )

      created_user = User.find_by(email: "newuser@example.com")
      expect(created_user.user_roles).to eq(["researcher", "other"])
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
    it "updates user roles on profile update" do
      user = create(:user, user_roles: ["ngo"])

      patch "/users", params: {
        user: {
          name: user.name,
          email: user.email,
          user_roles: ["private_sector", "other"],
          user_role_other: "Consultant"
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "user_roles" => ["private_sector", "other"],
        "user_role_other" => "Consultant"
      )

      user.reload
      expect(user.user_roles).to eq(["private_sector", "other"])
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
          user_roles: ["community"]
        }
      }, headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json["user"]).to include(
        "user_roles" => ["community"],
        "user_role_other" => nil
      )
    end
  end

  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {"Authorization" => "Bearer #{token}"}
  end
end

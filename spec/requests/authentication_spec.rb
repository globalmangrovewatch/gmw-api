require "swagger_helper"

RSpec.describe "Authentication", type: :request do
  before do
    ActionMailer::Base.default_url_options[:host] = "example.com"
    ENV["MRTT_UI_BASE_URL"] ||= "http://example.com"
  end

  path "/users/sign_in" do
    post "Login user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      description "Authenticates a user and returns a JWT token. Use this token in the Authorization header as 'Bearer <token>' for v3 endpoints."

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {type: :string, example: "user@example.com"},
              password: {type: :string, example: "password123"}
            },
            required: [:email, :password]
          }
        },
        required: [:user]
      }

      response 200, "Successful login" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "You are logged in."},
            token: {type: :string, example: "eyJhbGciOiJIUzI1NiJ9..."}
          },
          required: [:message, :token]

        let!(:existing_user) { create :user, email: "test@example.com", password: "password123", confirmed_at: Time.now }
        let(:user) do
          {
            user: {
              email: "test@example.com",
              password: "password123"
            }
          }
        end

        run_test!
      end

      response 401, "Invalid credentials" do
        schema type: :object,
          properties: {
            error: {type: :string, example: "Invalid Email or password."}
          }

        let(:user) do
          {
            user: {
              email: "wrong@example.com",
              password: "wrongpassword"
            }
          }
        end

        run_test!
      end
    end
  end

  path "/users/sign_out" do
    delete "Logout user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      description "Logs out the current user and invalidates the JWT token."
      security [bearerAuth: []]

      parameter name: :Authorization, in: :header, type: :string, required: true,
                description: "Bearer token", example: "Bearer eyJhbGciOiJIUzI1NiJ9..."

      response 200, "Successful logout" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "You are logged out."}
          }

        let!(:authenticated_user) { create :user, confirmed_at: Time.now }
        let(:Authorization) { auth_header(authenticated_user) }

        run_test!
      end
    end
  end

  path "/users" do
    post "Register new user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      description "Creates a new user account. A confirmation email will be sent."

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            allOf: [
              {"$ref" => "#/components/schemas/user_profile_input"},
              {
                type: :object,
                required: [:email, :password]
              }
            ]
          }
        },
        required: [:user]
      }

      response 200, "User created successfully" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "Signed up sucessfully."},
            user: {"$ref" => "#/components/schemas/user_profile"}
          },
          required: [:message, :user]

        let(:user) do
          {
            user: {
              email: "newuser@example.com",
              password: "password123",
              name: "John Doe",
              user_roles: ["scientist", "ngo"]
            }
          }
        end

        run_test!
      end

      response 422, "Validation errors" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "Email has already been taken"}
          }

        let!(:existing_user) { create :user, email: "existing@example.com" }
        let(:user) do
          {
            user: {
              email: "existing@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        end

        run_test!
      end
    end

    patch "Update user profile" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      description "Updates the authenticated user's profile, including profile roles."
      security [bearerAuth: []]

      parameter name: :Authorization, in: :header, type: :string, required: true,
                description: "Bearer token", example: "Bearer eyJhbGciOiJIUzI1NiJ9..."
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {"$ref" => "#/components/schemas/user_profile_input"}
        },
        required: [:user]
      }

      response 200, "Profile updated successfully" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "User profile updated sucessfully."},
            user: {"$ref" => "#/components/schemas/user_profile"}
          },
          required: [:message, :user]

        let!(:authenticated_user) do
          create :user, email: "profile@example.com", confirmed_at: Time.now, user_roles: ["ngo"]
        end
        let(:Authorization) { auth_header(authenticated_user) }
        let(:user) do
          {
            user: {
              name: authenticated_user.name,
              email: authenticated_user.email,
              user_roles: ["scientist", "other"],
              user_role_other: "Independent consultant"
            }
          }
        end

        run_test!
      end

      response 401, "Unauthorized" do
        let(:Authorization) { "Bearer invalid_token" }
        let(:user) do
          {
            user: {
              name: "Jane Doe",
              email: "jane@example.com",
              user_roles: ["scientist"]
            }
          }
        end

        run_test!
      end
    end
  end

  path "/users/password" do
    post "Request password reset" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      description "Sends a password reset email to the user."

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {type: :string, example: "user@example.com"}
            },
            required: [:email]
          }
        },
        required: [:user]
      }

      response 200, "Reset email sent" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "You will receive an email with instructions on how to reset your password in a few minutes."}
          }

        let!(:existing_user) { create :user, email: "user@example.com", confirmed_at: Time.now }
        let(:user) do
          {
            user: {
              email: "user@example.com"
            }
          }
        end

        run_test!
      end
    end
  end

  path "/users/current_user" do
    get "Get current user" do
      tags "Authentication"
      produces "application/json"
      description "Returns the currently authenticated user's information."
      security [bearerAuth: []]

      parameter name: :Authorization, in: :header, type: :string, required: true,
                description: "Bearer token", example: "Bearer eyJhbGciOiJIUzI1NiJ9..."

      response 200, "User retrieved successfully" do
        schema type: :object,
          properties: {
            user: {"$ref" => "#/components/schemas/user_profile"}
          },
          required: [:user]

        let!(:authenticated_user) do
          create :user,
            confirmed_at: Time.now,
            user_roles: ["government_policy", "other"],
            user_role_other: "Policy advisor"
        end
        let(:Authorization) { auth_header(authenticated_user) }

        run_test!
      end

      response 401, "Unauthorized" do
        let(:Authorization) { "Bearer invalid_token" }

        run_test!
      end
    end
  end

  def auth_header(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    "Bearer #{token}"
  end
end

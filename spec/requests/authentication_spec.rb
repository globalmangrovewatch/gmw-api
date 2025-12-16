require "swagger_helper"

RSpec.describe "Authentication", type: :request do
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

        let!(:user) { create :user, email: "test@example.com", password: "password123", confirmed_at: Time.now }
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

        let!(:user) { create :user, confirmed_at: Time.now }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }

        run_test!
      end

      response 401, "Unauthorized" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "Something went wrong"}
          }

        let(:Authorization) { "Bearer invalid_token" }

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
            type: :object,
            properties: {
              email: {type: :string, example: "newuser@example.com"},
              password: {type: :string, example: "password123"},
              password_confirmation: {type: :string, example: "password123"},
              name: {type: :string, example: "John Doe"}
            },
            required: [:email, :password, :password_confirmation]
          }
        },
        required: [:user]
      }

      response 200, "User created successfully" do
        schema type: :object,
          properties: {
            message: {type: :string, example: "Signed up successfully."},
            user: {
              type: :object,
              properties: {
                id: {type: :integer},
                email: {type: :string},
                name: {type: :string}
              }
            }
          }

        let(:user) do
          {
            user: {
              email: "newuser@example.com",
              password: "password123",
              password_confirmation: "password123",
              name: "John Doe"
            }
          }
        end

        run_test!
      end

      response 422, "Validation errors" do
        schema type: :object,
          properties: {
            error: {type: :string, example: "Email has already been taken"}
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

        let!(:user) { create :user, email: "user@example.com", confirmed_at: Time.now }
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
            email: {type: :string}
          }

        let!(:user) { create :user, confirmed_at: Time.now }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }

        run_test!
      end

      response 401, "Unauthorized" do
        let(:Authorization) { "Bearer invalid_token" }

        run_test!
      end
    end
  end

  def generate_jwt_token(user)
    secret = Rails.application.secret_key_base
    payload = {
      sub: user.id.to_s,
      scp: 'user',
      exp: 30.days.from_now.to_i,
      meta: {
        id: user.id,
        email: user.email,
        name: user.name,
        roles: {}
      }
    }
    JWT.encode(payload, secret, 'HS256')
  end
end


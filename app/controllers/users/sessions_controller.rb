class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  before_action :set_cors_headers
  respond_to :json

  def options
    head :ok
  end

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Accept'
    response.headers['Access-Control-Expose-Headers'] = 'Authorization'
  end

  def respond_with(resource, _opts = {})
    render json: {
      message: "You are logged in.",
      token: request.env["warden-jwt_auth.token"]
    }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: {message: "You are logged out."}, status: :ok
  end

  def log_out_failure
    render json: {message: "Something went wrong"}, status: :unauthorized
  end
end

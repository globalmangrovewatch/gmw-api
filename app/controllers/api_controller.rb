class ApiController < ActionController::API
  rescue_from Exception, with: :exception

  def exception(exception)
    puts exception
    render json: {error: exception}, status: :bad_request
  end

  protected

  def authenticate_user_from_token!
    auth_header = request.headers['Authorization']
    return nil unless auth_header
    
    token = auth_header.split(' ').last
    secret = ENV['SECRET_KEY_BASE'] || Rails.application.secret_key_base
    
    jwt_payload = JWT.decode(token, secret, true, { algorithm: 'HS256' }).first
    @current_user_id = jwt_payload['sub']
  rescue JWT::DecodeError, JWT::VerificationError
    nil
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find(@current_user_id) if @current_user_id
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def authenticate_user!
    authenticate_user_from_token!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end

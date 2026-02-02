class MrttApiController < ActionController::API
  before_action :authenticate_user!
  
  rescue_from Exception, with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  protected

  def exception(exception)
    Rails.logger.error "MrttApiController Exception: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace&.first(10)&.join("\n")
    render json: {error: "Unknown error occured"}, status: :bad_request
  end

  def record_not_unique(exception)
    value = exception.message.split(")=(")[1].split(")")[0]
    render json: {error: "'%s' already exists." % [value]}, status: :unprocessable_entity
  end

  def record_not_found(exception)
    render json: {error: "Record not found"}, status: :not_found
  end

  def insufficient_privilege
    render json: {message: "Insufficient privilege"}, status: :forbidden
  end

  def forbidden_role_change
    render json: {message: "Changing your own role is not allowed"}, status: :forbidden
  end

  private

  def authenticate_user_from_token!
    secret = Rails.application.secret_key_base
    jwt_payload = JWT.decode(request.headers['Authorization'].to_s.split(' ').last, 
                             secret, 
                             true, 
                             { algorithm: 'HS256' }).first
    @current_user_id = jwt_payload['sub']
  rescue JWT::DecodeError, JWT::VerificationError, JWT::ExpiredSignature
    nil
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find(@current_user_id) if @current_user_id
  rescue ActiveRecord::RecordNotFound
    @current_user = nil
  end

  def authenticate_user!
    authenticate_user_from_token!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end

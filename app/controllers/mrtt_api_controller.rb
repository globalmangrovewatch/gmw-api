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

  def enforce_admin_name_acknowledgement?
    !controller_path.start_with?("v3/")
  end

  def admin_name_acknowledged?
    ActiveModel::Type::Boolean.new.cast(params[:admin_name_acknowledged]) == true
  end

  def admin_name_acknowledgement
    return :missing unless params.key?(:admin_name_acknowledged)

    admin_name_acknowledged? ? :accepted : :declined
  end

  def block_unacknowledged_org_admin!(organization_ids)
    return false unless enforce_admin_name_acknowledgement?
    return false if current_user.is_admin
    return false if current_user.acknowledged_org_admin_of_all?(organization_ids)

    render json: {errors: {admin_name_acknowledged: ["must be accepted"]}}, status: :unprocessable_entity
    true
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

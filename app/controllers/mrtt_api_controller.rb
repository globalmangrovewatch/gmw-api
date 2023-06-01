class MrttApiController < ActionController::API
  before_action :authenticate_user!
  rescue_from Exception, with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  protected

  def exception(exception)
    puts exception
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
end

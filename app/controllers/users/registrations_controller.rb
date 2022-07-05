class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  skip_before_action :verify_authenticity_token
  respond_to :json

  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  private

  def record_not_unique(exception)
    value = exception.message.split(")=(")[1].split(")")[0]
    # TODO: Remove when email verification is in place
    render json: { "error": "'%s' already exists." % [value] }, status: :unprocessable_entity
  end

  def respond_with(resource, _opts = {})
    is_new = resource.created_at == resource.updated_at
    register_success && return if resource.persisted? && is_new
    update_success && return if resource.persisted? && !is_new
    process_failed
  end

  def update_success
    render json: { message: 'User profile updated sucessfully.' }
  end

  def register_success
    render json: { message: 'Signed up sucessfully.' }
  end

  def process_failed
    render json: {
      message: "#{resource.errors.full_messages.to_sentence}"
    }, status: :unprocessable_entity
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password)}
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :current_password)}
  end

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    return super if params["password"]&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except("current_password"))
  end

end

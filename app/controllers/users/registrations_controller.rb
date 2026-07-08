class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  skip_before_action :verify_authenticity_token
  respond_to :json

  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  private

  def record_not_unique(exception)
    value = exception.message.split(")=(")[1].split(")")[0]
    # TODO: Remove when email verification is in place
    render json: {error: "'%s' already exists." % [value]}, status: :unprocessable_entity
  end

  def respond_with(resource, _opts = {})
    is_new = resource.created_at == resource.updated_at
    register_success(resource) && return if resource.persisted? && is_new
    update_success(resource) && return if resource.persisted? && !is_new
    process_failed
  end

  def update_success(resource)
    render json: {
      message: "User profile updated sucessfully.",
      user: resource.profile_attributes
    }
  end

  def register_success(resource)
    render json: {
      message: "Signed up sucessfully.",
      user: resource.profile_attributes
    }
  end

  def process_failed
    render json: {
      message: resource.errors.full_messages.to_sentence.to_s
    }, status: :unprocessable_entity
  end

  def configure_permitted_parameters
    profile_params = [:name, :email, :password, :user_role_other, user_roles: []]
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(*profile_params) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(*profile_params, :current_password) }
  end

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    return super if params["password"]&.present?

    # Allows user to update registration information without password.
    resource.update_without_password(params.except("current_password"))
  end
end

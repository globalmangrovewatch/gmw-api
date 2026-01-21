class Users::PasswordsController < Devise::PasswordsController
  layout "mrtt_application"
  protect_from_forgery with: :null_session
  respond_to :json

  def create
    user = resource_class.find_by(email: resource_params[:email])
    if user
      source = params[:user][:source] || params[:source]
      user.send_reset_password_instructions_with_source(source)
    else
      resource_class.send_reset_password_instructions(resource_params)
    end
    
    render json: {
      message: "The password reset instruction was sent to %s" % resource_params[:email]
    }
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      render json: {
        message: "The password was reset successfully"
      }
    else
      render json: {
        error: resource.errors
      }
    end
  end
end

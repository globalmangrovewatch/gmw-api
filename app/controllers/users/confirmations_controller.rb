class Users::ConfirmationsController < Devise::ConfirmationsController
  private
  def after_confirmation_path_for(resource_name, resource)
    ENV["USER_CONFIRMATION_REDIRECT_URL"]
  end
end

class Users::ConfirmationsController < Devise::ConfirmationsController
  private
  def after_confirmation_path_for(resource_name, resource)
    ENV["MRTT_UI_BASE_URL"] + "/auth/login"
  end
end

class Users::ConfirmationsController < Devise::ConfirmationsController
  private
  def after_confirmation_path_for(resource_name, resource)
    url = ENV["MRTT_UI_BASE_URL"] + "/auth/login"
    redirect_to(url, allow_other_host: true) && return
  end
end

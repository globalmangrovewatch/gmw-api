class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      url = ENV["MRTT_UI_BASE_URL"] + "/auth/login"
      respond_with_navigational(resource) { redirect_to url, allow_other_host: true }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end

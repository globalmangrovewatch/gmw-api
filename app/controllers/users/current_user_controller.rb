class Users::CurrentUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: current_user.profile_attributes
    }
  end
end

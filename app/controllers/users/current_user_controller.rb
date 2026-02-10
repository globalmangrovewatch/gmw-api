class Users::CurrentUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: {
        name: current_user.name,
        email: current_user.email,
        organization: current_user.organization
      }
    }
  end
end

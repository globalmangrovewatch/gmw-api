class V2::UserLocationsController < MrttApiController
  before_action :set_user_location, only: [:show, :update, :destroy]

  def index
    @user_locations = current_user.user_locations.includes(:location).order(:position, :created_at)
  end

  def show
  end

  def create
    @user_location = current_user.user_locations.build(user_location_params)
    @user_location.custom_geometry = params[:custom_geometry] if params[:custom_geometry].present?

    if @user_location.save
      render :show, status: :created
    else
      render json: {errors: @user_location.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @user_location.assign_attributes(user_location_params)
    @user_location.custom_geometry = params[:custom_geometry] if params[:custom_geometry].present?

    if @user_location.save
      render :show
    else
      render json: {errors: @user_location.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @user_location.destroy
    head :no_content
  end

  def reorder
    positions = params[:positions]
    return render json: {error: "positions parameter required"}, status: :bad_request unless positions.is_a?(Array)

    ActiveRecord::Base.transaction do
      positions.each_with_index do |id, index|
        current_user.user_locations.find(id).update!(position: index)
      end
    end

    @user_locations = current_user.user_locations.order(:position)
    render :index
  end

  private

  def set_user_location
    @user_location = current_user.user_locations.find(params[:id])
  end

  def user_location_params
    params.permit(:name, :location_id, :position, :alerts_enabled, bounds: {})
  end
end


class V2::NotificationPreferencesController < MrttApiController
  def show
    @preferences = current_user.notification_preferences
  end

  def update
    if current_user.update_notification_preferences(notification_params)
      @preferences = current_user.notification_preferences
      render :show
    else
      render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def toggle_location_alerts
    current_value = current_user.subscribed_to_location_alerts || false
    new_value = !current_value
    if current_user.update(subscribed_to_location_alerts: new_value)
      @preferences = current_user.notification_preferences
      render :show
    else
      render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def bulk_toggle_location_alerts
    enabled = params[:enabled]
    return render json: {error: "enabled parameter required"}, status: :bad_request if enabled.nil?

    current_user.user_locations.update_all(alerts_enabled: enabled)
    @user_locations = current_user.user_locations.order(:position, :created_at)
    render "v2/user_locations/index"
  end

  private

  def notification_params
    params.permit(:location_alerts, :newsletter, :platform_updates)
  end
end


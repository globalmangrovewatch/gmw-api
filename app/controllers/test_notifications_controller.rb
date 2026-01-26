class TestNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_test
    unless params[:email].present?
      return render json: { error: "Email parameter is required" }, status: 400
    end

    NotificationService.send_notification(
      recipients: [params[:email]],
      subject: "Test Email from #{Rails.env.capitalize} Environment",
      body: "This is a test notification sent at #{Time.current}",
      deliver_later: true
    )

    render json: {
      message: "Email queued successfully!",
      sent_to: params[:email],
      environment: Rails.env
    }
  rescue => e
    render json: { error: e.message }, status: 422
  end
end

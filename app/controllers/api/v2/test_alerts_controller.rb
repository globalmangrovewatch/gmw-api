module Api
  module V2
    class TestAlertsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def show
        location_id = params[:location_id]

        unless TestAlertData.test_location?(location_id)
          render json: {error: "Only test locations (starting with 'test_') are supported"}, status: :bad_request
          return
        end

        test_data = TestAlertData.for_location(location_id)
        render json: test_data.as_response
      end

      def create
        location_id = params[:location_id] || "test_location"

        unless TestAlertData.test_location?(location_id)
          render json: {error: "Location ID must start with 'test_'"}, status: :bad_request
          return
        end

        test_data = TestAlertData.for_location(location_id)
        new_date = test_data.add_date!(params[:date], params[:count]&.to_i)

        render json: {
          message: "Added date #{new_date} to #{location_id}",
          current_dates: test_data.as_response
        }
      end

      def destroy
        location_id = params[:location_id] || "test_location"
        date = params[:date]

        test_data = TestAlertData.find_by(location_id: location_id)
        unless test_data
          render json: {error: "Test data not found for #{location_id}"}, status: :not_found
          return
        end

        if date
          test_data.remove_date!(date)
          render json: {message: "Removed date #{date}", current_dates: test_data.as_response}
        else
          test_data.reset!
          render json: {message: "Reset to default dates", current_dates: test_data.as_response}
        end
      end
    end
  end
end


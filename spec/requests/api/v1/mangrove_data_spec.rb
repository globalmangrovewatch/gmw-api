require "swagger_helper"

RSpec.describe "api/v1/locations/{location_id}/mangrove_data", type: :request do
  path "/api/v1/locations/{location_id}/mangrove_data" do
    get "Retrieves the data for the orginal widgets" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string
      parameter name: :year, in: :query, type: :integer

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/degradation_and_loss"}
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }
        example "application/json", :example_key, {
          data: [{}],
          metadata: {
            location_id: "1"
          }
        }
      end

      response 500, "Error 500" do
        schema :type => :object,
          "$ref" => "#/components/schemas/error_response"

        example "application/json", :example_key, {

          location_id: "1"
        }
      end
    end
  end
end

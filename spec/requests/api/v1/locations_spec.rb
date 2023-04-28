require "swagger_helper"

RSpec.describe "API V1 Locations", type: :request do
  path "/api/v1/locations" do
    get "Retrieves the data for the degradation and loss Treemap chart" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :rank_by, in: :query, type: :string
      parameter name: :dir, in: :query, type: :string
      parameter name: :start_date, in: :query, type: :string
      parameter name: :end_date, in: :query, type: :string
      parameter name: :location_type, in: :query, type: :string
      parameter name: :limit, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/location_v1"}
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

  path "/api/v1/locations/{location_id}" do
    get "Retrieves the data for the degradation and loss Treemap chart" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/location_v1"}
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

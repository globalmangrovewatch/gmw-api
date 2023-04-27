require "swagger_helper"

RSpec.describe "api/v2/spatial_file", type: :request do
  path "/api/v2/spatial_file/converter" do
    post "Converts a geospatial format into a valid geojson" do
      tags "file_converter"
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, type: :file, required: true
      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/file_converter"
            }
          }
        example "application/json", :example_key, {
          data: {
            type: "FeatureCollection",
            features: [
              {
                type: "Feature",
                geometry: {
                  type: "Polygon",
                  coordinates: [
                    [
                      [
                        -122.422,
                        37.777
                      ],
                      [
                        -122.422,
                        37.777
                      ],
                      [
                        -122.422,
                        37.777
                      ],
                      [
                        -122.422,
                        37.777
                      ],
                      [
                        -122.422,
                        37.777
                      ]
                    ]
                  ]
                }
              }
            ]
          }
        }
      end

      response 500, "Error 500" do
        schema :type => :object,
          "$ref" => "#/components/schemas/error_response"

        example "application/json", :example_key, {
          error: "1"
        }
      end
    end
  end
end

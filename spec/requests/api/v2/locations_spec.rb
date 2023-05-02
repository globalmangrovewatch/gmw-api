require "swagger_helper"

RSpec.describe "API V2 Locations", type: :request do
  path "/api/v2/locations" do
    get "Retrieves the data for the biodiversity widget" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"

      let!(:location_1) { create :location }
      let!(:location_2) { create :location }
      let!(:habitat_extent) { create :habitat_extent, location: location_1 }
      let!(:ignored_location) { create :location, location_type: "aoi" }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/location_v2"}
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/locations/index")
        end

        it "ignores aoi location types" do
          expect(response_json["data"].pluck("id")).not_to include(ignored_location.id)
        end
      end
    end

    post "Creates a new location" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          location_type: {type: :string},
          iso: {type: :string}
        },
        required: %w[name location_type iso]
      }

      let(:location_params) do
        {name: "Test Location", location_type: "country", iso: "TST"}
      end

      response 201, "Created" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/location_v2"
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/locations/create")
        end
      end

      response 422, "Unprocessable Entity" do
        let(:location_params) { {name: nil} }

        run_test!
      end
    end
  end

  path "/api/v2/locations/{location_id}", type: :request do
    get "Retrieves the data for the biodiversity widget" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string, required: true

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/location_v2"
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when searching by country iso" do
          let(:location) { create :location, location_type: "country" }
          let(:location_id) { location.iso }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/locations/show")
          end
        end

        context "when searching by location_id" do
          let(:location) { create :location, location_type: "country" }
          let(:location_id) { location.location_id }

          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/locations/show")
          end
        end

        response 400, "Not Found" do
          let(:location_id) { "WRONG_ID" }

          run_test!
        end
      end
    end

    put "Updates the data of a location" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string, required: true
      parameter name: :location_params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          location_type: {type: :string},
          iso: {type: :string}
        },
        required: %w[name location_type iso]
      }

      let(:location) { create :location }
      let(:location_id) { location.location_id }
      let(:location_params) do
        {name: "Test Location", location_type: "country", iso: "TST"}
      end

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/location_v2"
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/locations/update")
        end
      end

      response 400, "Not Found" do
        let(:location_id) { "WRONG_ID" }

        run_test!
      end
    end

    delete "Deletes a location" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string, required: true

      let(:location) { create :location }
      let(:location_id) { location.location_id }

      response 204, "Success" do
        run_test!
      end

      response 400, "Not Found" do
        let(:location_id) { "WRONG_ID" }

        run_test!
      end
    end
  end
end

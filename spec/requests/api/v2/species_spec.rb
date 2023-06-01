require "swagger_helper"

RSpec.describe "API V2 Species", type: :request do
  path "/api/v2/species" do
    get "Retrieves data for species" do
      tags "Species"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id", required: false

      let(:location) { create :location }
      let!(:species_1) { create :specie, locations: [location] }
      let!(:species_2) { create :specie }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/specie"}
            }
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/species/index")
        end

        context "when location_id is provided" do
          let(:location_id) { location.id }

          run_test!

          it "returns correct data" do
            expect(response_json["data"].pluck("scientific_name")).to eq([species_1.scientific_name])
          end
        end
      end
    end
  end
end

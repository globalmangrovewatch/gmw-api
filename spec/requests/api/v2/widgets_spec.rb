require "swagger_helper"

RSpec.describe "API V2 Widgets", type: :request do
  path "/api/v2/widgets/protected-areas" do
    get "Retrieves the data for the protected area widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false
      parameter name: :units, in: :query, type: :string, enum: ["km2", "ha", "m"], description: "Units of result. Default: ha", required: false

      let(:location) { create :location }
      let!(:widget_protected_area_1) { create :widget_protected_area, location: location }
      let!(:widget_protected_area_2) { create :widget_protected_area }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/protected_areas"}
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/protected_areas_get_location")
          end

          it "returns correct id of found record" do
            expect(response_json["data"].pluck("id")).to eq([widget_protected_area_1.id])
          end

          it "uses correct default unit" do
            expect(response_json.dig("metadata", "units", "total_area")).to eq("ha")
            expect(response_json.dig("metadata", "units", "protected_area")).to eq("ha")
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/protected_areas_get_worldwide")
          end
        end

        context "when changing unit" do
          let(:units) { "km2" }

          run_test!

          it "uses correct correct unit" do
            expect(response_json.dig("metadata", "units", "total_area")).to eq(units)
            expect(response_json.dig("metadata", "units", "protected_area")).to eq(units)
          end
        end
      end
    end
  end

  path "/api/v2/widgets/protected-areas/import" do
    post "Uploads the data for Protected areas" do
      tags "Widgets"
      consumes "multipart/form-data"
      parameter name: :file, in: :formData, type: :file, description: "File in CSV format", required: true

      let!(:location_1) { create :location, location_id: "Location-1" }
      let!(:location_2) { create :location, location_id: "Location-2" }
      let(:file) { fixture_file_upload "protected_areas_import.csv" }

      response 201, "Import was successful" do
        run_test!
      end

      response 400, "Location was not found" do
        before { location_1.destroy }

        run_test!
      end
    end
  end

  path "/api/v2/widgets/biodiversity" do
    get "Retrieves the data for the biodiversity widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:location) { create :location }
      let!(:specie_1) { create :specie, locations: [location] }
      let!(:specie_2) { create :specie }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/biodiversity"
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/biodiversity_get_location")
          end

          it "returns correct id of found record" do
            expect(response_json["data"]["species"].pluck("id")).to eq([specie_1.id])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/biodiversity_get_worldwide")
          end
        end
      end
    end
  end

  path "/api/v2/widgets/restoration-potential" do
    get "Retrieves the data for the restoration potential chart" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false
      parameter name: :year, in: :query, type: :integer, description: "Year. Default: last year which contains data", required: false

      let(:location) { create :location }
      let!(:restorable_area) do
        create :restoration_potential, location: location, year: 2019, indicator: "restorable_area"
      end
      let!(:restoration_potential_score) do
        create :restoration_potential, location:location, year: 2019, indicator: "restoration_potential_score"
      end
      let!(:mangrove_area) do
        create :restoration_potential, year: 2019, indicator: "mangrove_area"
      end
      let!(:restoration_potential_old_year) do
        create :restoration_potential, year: 2018, indicator: "restorable_area"
      end

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/restoration_potential"
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/restoration_potential_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"]["restorable_area"]).to eq(restorable_area.value)
            expect(response_json["data"]["mangrove_area_extent"]).to be_nil
            expect(response_json["data"]["restoration_potential_score"]).to eq(restoration_potential_score.value)
          end

          it "returns correct years" do
            expect(response_json["metadata"]["year"]).to eq([2019, 2018])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/restoration_potential_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"]["restorable_area"]).to eq(restorable_area.value)
            expect(response_json["data"]["mangrove_area_extent"]).to eq(mangrove_area.value)
            expect(response_json["data"]["restoration_potential_score"]).to eq(68)
          end

          context "when filtered for specific year" do
            let(:year) { 2018 }

            run_test!

            it "returns correct data" do
              expect(response_json["data"]["restorable_area"]).to eq(restoration_potential_old_year.value)
              expect(response_json["data"]["mangrove_area_extent"]).to be_nil
              expect(response_json["data"]["restoration_potential_score"]).to eq(68)
            end
          end
        end
      end
    end
  end

  path "/api/v2/widgets/degradation-and-loss" do
    get "Retrieves the data for the degradation and loss Treemap chart" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false
      parameter name: :year, in: :query, type: :integer, description: "Year. Default: last year which contains data", required: false

      let(:location) { create :location }
      let!(:degraded_area) do
        create :degradation_treemap, location: location, year: 2019, indicator: "degraded_area"
      end
      let!(:lost_area) do
        create :degradation_treemap, location: location, year: 2019, indicator: "lost_area"
      end
      let!(:mangrove_area) do
        create :degradation_treemap, year: 2019, indicator: "mangrove_area"
      end
      let!(:restorable_area) do
        create :degradation_treemap, year: 2019, indicator: "restorable_area"
      end
      let!(:degraded_area_old_year) do
        create :degradation_treemap, year: 2018, indicator: "degraded_area"
      end

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/degradation_and_loss_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].find { |r| r["indicator"] == "degraded_area" }&.dig("value")).to eq(degraded_area.value)
            expect(response_json["data"].find { |r| r["indicator"] == "lost_area" }&.dig("value")).to eq(lost_area.value - restorable_area.value)
            expect(response_json["data"].find { |r| r["indicator"] == "mangrove_area" }&.dig("value")).to be_nil
            expect(response_json["data"].find { |r| r["indicator"] == "restorable_area" }&.dig("value")).to be_nil
          end

          it "returns correct years" do
            expect(response_json["metadata"]["year"]).to eq([2019, 2018])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/degradation_and_loss_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].find { |r| r["indicator"] == "degraded_area" }&.dig("value")).to eq(degraded_area.value)
            expect(response_json["data"].find { |r| r["indicator"] == "lost_area" }&.dig("value")).to eq(lost_area.value - restorable_area.value)
            expect(response_json["data"].find { |r| r["indicator"] == "mangrove_area" }&.dig("value")).to eq(mangrove_area.value)
            expect(response_json["data"].find { |r| r["indicator"] == "restorable_area" }&.dig("value")).to eq(restorable_area.value)
          end

          context "when filtered for specific year" do
            let(:year) { 2018 }

            run_test!

            it "returns correct data" do
              expect(response_json["data"].find { |r| r["indicator"] == "degraded_area" }&.dig("value")).to eq(degraded_area_old_year.value)
              expect(response_json["data"].find { |r| r["indicator"] == "lost_area" }&.dig("value")).to be_nil
              expect(response_json["data"].find { |r| r["indicator"] == "mangrove_area" }&.dig("value")).to be_nil
              expect(response_json["data"].find { |r| r["indicator"] == "restorable_area" }&.dig("value")).to be_nil
            end
          end
        end
      end
    end
  end

  path "/api/v2/widgets/blue-carbon-investment" do
    get "Retrieves the data for the blue carbon investment chart" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false
      parameter name: :units, in: :query, type: :string, enum: ["km2", "ha", "m"], description: "Units of result. Default: ha", required: false

      let(:location) { create :location }
      let!(:blue_carbon_investment_1) { create :blue_carbon_investment, location: location }
      let!(:blue_carbon_investment_2) { create :blue_carbon_investment }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/blue_carbon_investment"}
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/blue_carbon_investment_get_location")
          end

          it "uses correct default unit" do
            expect(response_json.dig("metadata", "unit")).to eq("ha")
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/blue_carbon_investment_get_worldwide")
          end
        end

        context "when changing unit" do
          let(:units) { "km2" }

          run_test!

          it "uses correct correct unit" do
            expect(response_json.dig("metadata", "unit")).to eq(units)
          end
        end
      end
    end
  end

  path "/api/v2/widgets/international_status" do
    get "Retrieves the data for the international status widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:location) { create :location }
      let!(:international_status_1) { create :international_status, location: location }
      let!(:international_status_2) { create :international_status }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/international_status"}
            },
            metadata: {
              :type => :object,
              "$ref" => "#/components/schemas/metadata"
            }
          }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/international_status_get_location")
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/international_status_get_worldwide")
          end
        end
      end
    end
  end

  path "/api/v2/widgets/ecosystem_services" do
    get "Retrieves the data for the ecosystem services widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/ecosystem_service"}
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

  path "/api/v2/widgets/habitat_extent" do
    get "Retrieves the data for the habitat extent widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/habitat_extent"}
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

  path "/api/v2/widgets/net_change" do
    get "Retrieves the data for the net change widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/net_change"}
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

  path "/api/v2/widgets/aboveground_biomass" do
    get "Retrieves the data for the aboveground_biomass widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/aboveground_biomass"}
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

  path "/api/v2/widgets/tree_height" do
    get "Retrieves the data for the tree height widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/tree_height"}
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

  path "/api/v2/widgets/blue_carbon" do
    get "Retrieves the data for the blue carbon widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/blue_carbon"}
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

  path "/api/v2/widgets/mitigation_potentials" do
    get "Retrieves the data for the mitigation potential widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/mitigation_potentials"}
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

  path "/api/v2/widgets/country_ranking" do
    get "Retrieves the data for the mitigation potential widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string
      parameter name: :start_year, in: :query, type: :integer, default: 2007
      parameter name: :end_year, in: :query, type: :integer, default: 2020

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/country_ranking"}
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

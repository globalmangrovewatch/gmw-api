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

      let(:location_1) { create :location }
      let(:location_2) { create :location }
      let!(:specie_1) { create :specie, locations: [location_1] }
      let!(:specie_2) { create :specie, locations: [location_2] }

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
          let(:location_id) { location_1.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/biodiversity_get_location")
          end

          it "returns correct id of found record" do
            expect(response_json["data"]["species"].pluck("id")).to eq([specie_1.id])
            expect(response_json["metadata"]["worldwide_total"]).to eq(2)
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/biodiversity_get_worldwide")
          end

          it "returns correct id of found records" do
            expect(response_json["data"]["species"].pluck("id")).to eq([specie_1.id, specie_2.id])
            expect(response_json["metadata"]["worldwide_total"]).to eq(2)
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
        create :restoration_potential, location: location, year: 2019, indicator: "restoration_potential_score"
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
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false
      parameter name: :slug, in: :query, type: :string, description: "Slug of the ecosystem service. Default: all", required: false

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

        let(:location) { create :location }
        let!(:ecosystem_service_1) { create :ecosystem_service, location: location, indicator: "bivalve" }
        let!(:ecosystem_service_2) { create :ecosystem_service, indicator: "AGB" }

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/ecosystem_services_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("indicator")).to match_array(EcosystemService.indicators.keys)
            expect(response_json["data"].pluck("value").compact).to eq([ecosystem_service_1.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/ecosystem_services_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("indicator")).to match_array(EcosystemService.indicators.keys)
            expect(response_json["data"].pluck("value").compact).to match_array([ecosystem_service_1.value, ecosystem_service_2.value])
          end

          context "when filtering by slug" do
            let(:slug) { "restoration-value" }

            it "returns correct data" do
              expect(response_json["data"].pluck("indicator")).to match_array(%w[AGB SOC])
              expect(response_json["data"].pluck("value")).to match_array([nil, ecosystem_service_2.value])
            end
          end
        end
      end
    end
  end

  path "/api/v2/widgets/habitat_extent" do
    get "Retrieves the data for the habitat extent widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let!(:worldwide) { create :location, :worldwide }
      let(:country_location) { create :location, location_type: "country" }
      let(:location) { create :location }
      let!(:habitat_extent_1) { create :habitat_extent, location: country_location, indicator: "linear_coverage" }
      let!(:habitat_extent_2) { create :habitat_extent, location: country_location, indicator: "habitat_extent_area" }
      let!(:habitat_extent_3) { create :habitat_extent, location: location }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/habitat_extent_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([habitat_extent_3.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/habitat_extent_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to match_array([habitat_extent_1.value, habitat_extent_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/net_change" do
    get "Retrieves the data for the net change widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let!(:worldwide) { create :location, :worldwide }
      let(:country_location) { create :location, location_type: "country" }
      let(:location) { create :location }
      let!(:habitat_extent_1) { create :habitat_extent, location: country_location, indicator: "habitat_extent_area", year: 2010 }
      let!(:habitat_extent_2) { create :habitat_extent, location: country_location, indicator: "habitat_extent_area", year: 2020 }
      let!(:habitat_extent_3) { create :habitat_extent, location: location, indicator: "habitat_extent_area", year: 2012 }
      let!(:habitat_extent_4) { create :habitat_extent, location: location, indicator: "habitat_extent_area", year: 2013 }
      let!(:ignored_habitat_extent) { create :habitat_extent, location: location, indicator: "linear_coverage" }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/net_change_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("net_change")).to eq([0, habitat_extent_4.value - habitat_extent_3.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/net_change_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("net_change")).to eq([0, habitat_extent_2.value - habitat_extent_1.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/aboveground_biomass" do
    get "Retrieves the data for the aboveground_biomass widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let!(:worldwide) { create :location, :worldwide }
      let(:country_location) { create :location, location_type: "country" }
      let(:location) { create :location }
      let!(:aboveground_biomass_1) { create :aboveground_biomass, location: country_location, indicator: "total" }
      let!(:aboveground_biomass_2) { create :aboveground_biomass, location: country_location, indicator: "150-250" }
      let!(:aboveground_biomass_3) { create :aboveground_biomass, location: location }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/aboveground_biomass_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([aboveground_biomass_3.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/aboveground_biomass_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to match_array([aboveground_biomass_1.value, aboveground_biomass_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/tree_height" do
    get "Retrieves the data for the tree height widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:country_location) { create :location, location_type: "country" }
      let(:location) { create :location }
      let!(:tree_height_1) { create :tree_height, location: country_location, year: 2020, indicator: "0-5" }
      let!(:tree_height_2) { create :tree_height, location: country_location, year: 2022, indicator: "10-15" }
      let!(:tree_height_3) { create :tree_height, location: location, indicator: "0-5" }
      let!(:ignored_tree_height) { create :tree_height, location: country_location, year: 2020, indicator: "avg" }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/tree_height_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([tree_height_3.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/tree_height_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to match_array([tree_height_1.value, tree_height_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/blue_carbon" do
    get "Retrieves the data for the blue carbon widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:country_location) { create :location, location_type: "country" }
      let(:location) { create :location }
      let!(:blue_carbon_1) { create :blue_carbon, location: country_location }
      let!(:blue_carbon_2) { create :blue_carbon, location: country_location }
      let!(:blue_carbon_3) { create :blue_carbon, location: location }
      let!(:ignored_blue_carbon) { create :blue_carbon, location: location, indicator: "toc" }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/blue_carbon_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([blue_carbon_3.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/blue_carbon_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to match_array([blue_carbon_1.value, blue_carbon_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/mitigation_potentials" do
    get "Retrieves the data for the mitigation potential widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:location) { create :location }
      let!(:mitigation_potential_1) { create :mitigation_potential, location: location }
      let!(:mitigation_potential_2) { create :mitigation_potential }

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

        context "when location_id is used" do
          let(:location_id) { location.id }

          run_test!

          it "matches snapshot", generate_swagger_example: true do
            expect(response.body).to match_snapshot("api/v2/widgets/mitigation_potentials_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([mitigation_potential_1.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/mitigation_potentials_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to match_array([mitigation_potential_1.value, mitigation_potential_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/country_ranking" do
    get "Retrieves the data for the mitigation potential widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :start_year, in: :query, type: :integer, description: "Start year. Default: first year that data exists for", required: false
      parameter name: :end_year, in: :query, type: :integer, description: "End year. Default: last year that dat exists for", required: false

      let(:location) { create :location, location_type: "country" }
      let!(:habitat_extent_1) { create :habitat_extent, location: location, indicator: "habitat_extent_area", year: 2010 }
      let!(:habitat_extent_2) { create :habitat_extent, location: location, indicator: "habitat_extent_area", year: 2015 }
      let!(:habitat_extent_3) { create :habitat_extent, location: location, indicator: "habitat_extent_area", year: 2020 }
      let!(:ignored_habitat_extent) { create :habitat_extent, indicator: "linear_coverage" }

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

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/widgets/country_ranking")
        end

        it "returns the correct data" do
          expect(response_json["data"].pluck("abs_value")).to eq([(habitat_extent_1.value - habitat_extent_3.value).abs])
        end

        context "when filtered just for specific year" do
          let(:start_year) { habitat_extent_1.year }
          let(:end_year) { habitat_extent_2.year }

          it "returns the correct data" do
            expect(response_json["data"].pluck("abs_value")).to eq([(habitat_extent_1.value - habitat_extent_2.value).abs])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/drivers_of_change" do
    get "Retrieves the data for the drivers of change widget" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string, description: "Location id. Default: worldwide", required: false

      let(:location) { create :location }
      let(:worldwide) { create :location, :worldwide }
      let!(:drivers_of_change_1) { create :drivers_of_change, location: location }
      let!(:drivers_of_change_2) { create :drivers_of_change, location: worldwide }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/drivers_of_change"}
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
            expect(response.body).to match_snapshot("api/v2/widgets/drivers_of_change_get_location")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([drivers_of_change_1.value])
          end
        end

        context "when location_id is missing - use worldwide" do
          run_test!

          it "matches snapshot" do
            expect(response.body).to match_snapshot("api/v2/widgets/drivers_of_change_get_worldwide")
          end

          it "returns correct data" do
            expect(response_json["data"].pluck("value")).to eq([drivers_of_change_2.value])
          end
        end
      end
    end
  end

  path "/api/v2/widgets/sites_filters" do
    get "Retrieves the data used for filtering sites" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"

      let!(:organization) { create :organization }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {"$ref" => "#/components/schemas/sites_filters"}
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/widgets/sites_filters")
        end
      end
    end
  end

  path "/api/v2/widgets/sites" do
    get "Retrieves the data for the sites" do
      tags "Widgets"
      consumes "application/json"
      produces "application/json"
      parameter name: :organization, in: :query, type: :array, items: {type: :string}, description: "Organization name", required: false
      parameter name: :ecological_aim, in: :query, type: :array, items: {type: :string}, required: false
      parameter name: :socioeconomic_aim, in: :query, type: :array, items: {type: :string}, required: false
      parameter name: :cause_of_decline, in: :query, type: :array, items: {type: :string}, required: false
      parameter name: :intervention_type, in: :query, type: :array, items: {type: :string}, required: false
      parameter name: :community_activities, in: :query, type: :array, items: {type: :string}, required: false

      let(:organization_1) { create :organization }
      let(:landscape_1) { create :landscape, organizations: [organization_1] }
      let(:registration_intervention_answer_1) do
        create :registration_intervention_answer,
          question_id: "3.1",
          answer_value: {
            "selectedValues" => ["Increase native flora/vegetation (non-mangrove)", "Increase habitat connectivity"],
            "otherValue" => "test",
            "isOtherChecked" => true,
            "aimStakeholderBenefits" => {}
          }
      end
      let(:registration_intervention_answer_2) do
        create :registration_intervention_answer,
          question_id: "3.2",
          answer_value: {
            "selectedValues" => ["Tourism and recreation", "Safeguard cultural or spiritual importance", "Unknown", "None"],
            "isOtherChecked" => false
          }
      end
      let(:registration_intervention_answer_3) do
        create :registration_intervention_answer,
          question_id: "4.2",
          answer_value: [
            {"mainCauseLabel" => "Residential & commercial development",
             "mainCauseAnswers" => [{"mainCauseAnswer" => "Housing & urban areas", "levelOfDegredation" => "Moderate"}]},
            {"mainCauseLabel" => "Agriculture & aquaculture",
             "subCauses" =>
                    [{"subCauseLabel" => "Marine & freshwater aquaculture",
                      "subCauseAnswers" => [{"subCauseAnswer" => "Shrimp aquaculture", "levelOfDegredation" => "High"}]}]},
            {"mainCauseLabel" => "Natural system modifications",
             "subCauses" =>
                    [{"subCauseLabel" => "Dams & water management/use",
                      "subCauseAnswers" =>
                        [{"subCauseAnswer" => "Reduced sediment flows", "levelOfDegredation" => "High"},
                          {"subCauseAnswer" => "Reduction in flows/altered hydrology", "levelOfDegredation" => "High"}]}]},
            {"mainCauseLabel" => "Climate change & severe weather",
             "mainCauseAnswers" =>
                    [{"mainCauseAnswer" => "Sea level change", "levelOfDegredation" => "Low"},
                      {"mainCauseAnswer" => "Storms & flooding", "levelOfDegredation" => "Moderate"}]}
          ]
      end
      let(:registration_intervention_answer_4) do
        create :registration_intervention_answer,
          question_id: "6.2",
          answer_value: {
            "selectedValues" => ["Vegetation clearance and suppression"], "isOtherChecked" => true, "otherValue" => "planting"
          }
      end
      let(:registration_intervention_answer_5) do
        create :registration_intervention_answer,
          question_id: "6.4",
          answer_value: {
            "selectedValues" => ["Formal mangrove protection ", "None"], "isOtherChecked" => false
          }
      end
      let!(:site_1) { create :site, landscape: landscape_1 }
      let!(:site_2) { create :site, registration_intervention_answers: [registration_intervention_answer_1, registration_intervention_answer_2, registration_intervention_answer_3] }
      let!(:site_3) { create :site, registration_intervention_answers: [registration_intervention_answer_4, registration_intervention_answer_5] }
      let!(:site_4) { create :site }

      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {"$ref" => "#/components/schemas/sites"}
            }
          }

        run_test!

        it "matches snapshot", generate_swagger_example: true do
          expect(response.body).to match_snapshot("api/v2/widgets/sites")
        end

        it "contains all available sites" do
          expect(response_json["data"].pluck("id")).to match_array(Site.pluck(:id))
        end

        context "when used organization filter" do
          let(:organization) { [organization_1.organization_name] }

          it "contains only sites for given organization" do
            expect(response_json["data"].pluck("id")).to eq([site_1.id])
          end
        end

        context "when used ecological_aim filter" do
          let(:ecological_aim) { ["Increase native flora/vegetation (non-mangrove)"] }

          it "contains only sites for given ecological_aim" do
            expect(response_json["data"].pluck("id")).to eq([site_2.id])
          end
        end

        context "when used socioeconomic_aim filter" do
          let(:socioeconomic_aim) { ["Tourism and recreation"] }

          it "contains only sites for given socioeconomic_aim" do
            expect(response_json["data"].pluck("id")).to eq([site_2.id])
          end
        end

        context "when used cause_of_decline filter" do
          let(:cause_of_decline) { ["Residential %26 commercial development"] }

          it "contains only sites for given cause_of_decline" do
            expect(response_json["data"].pluck("id")).to eq([site_2.id])
          end
        end

        context "when used intervention_type filter" do
          let(:intervention_type) { ["Vegetation clearance and suppression"] }

          it "contains only sites for given intervention_type" do
            expect(response_json["data"].pluck("id")).to eq([site_3.id])
          end
        end

        context "when used community_activities filter" do
          let(:community_activities) { ["Formal mangrove protection"] }

          it "contains only sites for given community_activities" do
            expect(response_json["data"].pluck("id")).to eq([site_3.id])
          end
        end

        context "when using multiple filters together" do
          let(:ecological_aim) { ["Increase native flora/vegetation (non-mangrove)"] }
          let(:socioeconomic_aim) { ["Tourism and recreation"] }
          let(:cause_of_decline) { ["Residential %26 commercial development"] }

          it "contains only sites for given filters" do
            expect(response_json["data"].pluck("id")).to eq([site_2.id])
          end
        end
      end
    end
  end
end

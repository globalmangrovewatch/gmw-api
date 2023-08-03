# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  config.after :each, generate_swagger_example: true do |example|
    example.metadata[:response][:content] = {
      "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
    }
  end

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v2/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "API docs",
        version: "v2"
      },
      paths: {},
      servers: [
        {
          url: "https://mangrove-atlas-api-staging.herokuapp.com",
          description: "staging api url"
        },
        {
          url: "https://mangrove-atlas-api.herokuapp.com",
          description: "production api url"
        }
      ],
      components: {
        schemas: {
          metadata: {
            type: :object,
            properties: {
              location_id: {type: :string, nullable: true},
              unit: {type: :string, nullable: true},
              units: {type: :object, nullable: true},
              years: {
                type: :array,
                items: {type: :number},
                nullable: true
              },
              periods: {
                type: :array,
                items: {type: :string},
                nullable: true
              },
              min: {type: :number, nullable: true},
              max: {type: :number, nullable: true},
              note: {type: :string, nullable: true},
              worldwide_total: {type: :number, nullable: true, description: "total number of species in the world"},
              location_resources: {
                type: :array,
                items: {"$ref" => "#/components/schemas/location_resource"},
                nullable: true
              }
            }
          },
          error_response: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  message: {type: :string, nullable: true}
                }
              }
            },
            required: [:error]
          },
          location_v1: {
            type: :object,
            properties: {
              id: {type: :string},
              createdAt: {type: :string},
              state: {type: :string},
              joiningDate: {type: :string},
              homeAddress: {
                type: :object,
                properties: {
                  address1: {type: :string},
                  address2: {type: :string, nullable: true},
                  city: {type: :string},
                  state: {type: :string},
                  postalCode: {type: :string}
                },
                required: []
              },
              medicareRequested: {type: :boolean},
              compensationUsdCents: {type: :integer,
                                     description: "compensation"}
            },
            required: []
          },
          location_v2: {
            type: :object,
            properties: {
              id: {type: :integer},
              created_at: {type: :string},
              name: {type: :string},
              location_type: {type: :string},
              iso: {type: :string},
              location_id: {type: :string, nullable: true},
              coast_length_m: {type: :number, nullable: true},
              area_m2: {type: :number, nullable: true}
            },
            required: []
          },
          specie: {
            type: :object,
            properties: {
              id: {type: :integer},
              scientific_name: {type: :string},
              common_name: {type: :string, nullable: true},
              name: {type: :string, nullable: true},
              iucn_url: {type: :string, nullable: true},
              red_list_cat: {type: :string},
              location_ids: {type: :array, items: {type: :integer}}
            }
          },
          protected_areas: {
            type: :object,
            properties: {
              id: {type: :integer, nullable: true},
              year: {type: :integer},
              total_area: {type: :number},
              protected_area: {type: :number}
            },
            required: []
          },
          biodiversity: {
            type: :object,
            properties: {
              total: {type: :integer},
              threatened: {type: :integer},
              categories: {
                type: :object,
                properties: {
                  cr: {type: :integer, nullable: true},
                  en: {type: :integer, nullable: true},
                  nt: {type: :integer, nullable: true},
                  lc: {type: :integer, nullable: true}
                }
              },
              species: {
                type: :array,
                items: {
                  "$ref": "#/components/schemas/specie"
                }
              }
            },
            required: [:total, :threatened, :categories]
          },
          restoration_potential: {
            type: :object,
            properties: {
              restoration_potential_score: {type: :number},
              restorable_area: {type: :number, nullable: true},
              restorable_area_perc: {type: :number, nullable: true},
              mangrove_area_extent: {type: :number, nullable: true}
            },
            required: [:restoration_potential_score, :restorable_area, :restorable_area_perc, :mangrove_area_extent]
          },
          degradation_and_loss: {
            type: :object,
            properties: {
              indicator: {type: :string},
              label: {type: :string},
              value: {type: :number}
            },
            required: [:indicator, :value]
          },
          blue_carbon_investment: {
            type: :object,
            properties: {
              category: {type: :string},
              value: {type: :number},
              percentage: {type: :number},
              description: {type: :string},
              label: {type: :string}
            },
            required: [:category, :value, :percentage, :description]
          },
          international_status: {
            type: :object,
            properties: {
              base_years: {type: :string},
              fow: {type: :string},
              frel: {type: :string},
              ipcc_wetlands_suplement: {type: :string},
              ndc: {type: :string},
              ndc_adaptation: {type: :string},
              ndc_blurb: {type: :string},
              ndc_mitigation: {type: :string},
              ndc_reduction_target: {type: :string},
              ndc_target: {type: :string},
              ndc_target_url: {type: :string},
              ndc_updated: {type: :string},
              pledge_summary: {type: :string},
              pledge_type: {type: :string},
              target_years: {type: :string},
              year_frel: {type: :string}
            }
          },
          ecosystem_service: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number, nullable: true}
            },
            required: [:indicator, :value]
          },
          habitat_extent: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              year: {type: :number}
            },
            required: [:indicator, :value, :year]
          },
          net_change: {
            type: :object,
            properties: {
              net_change: {type: :number},
              year: {type: :number},
              gain: {type: :number, nullable: true},
              loss: {type: :number, nullable: true}
            },
            required: [:net_change, :year]
          },
          aboveground_biomass: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              year: {type: :number}
            },
            required: [:indicator, :value, :year]
          },
          tree_height: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              year: {type: :number}
            },
            required: [:indicator, :value, :year]
          },
          blue_carbon: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              year: {type: :number}
            },
            required: [:indicator, :value, :year]
          },
          mitigation_potentials: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              year: {type: :number},
              category: {type: :string}
            },
            required: [:indicator, :value, :year, :category]
          },
          country_ranking: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              abs_value: {type: :number},
              name: {type: :string},
              iso: {type: :string}
            },
            required: [:indicator, :value]
          },
          drivers_of_change: {
            type: :object,
            properties: {
              variable: {type: :string},
              value: {type: :number},
              primary_driver: {type: :string}
            }
          },
          national_dashboard: {
            type: :object,
            properties: {
              indicator: {type: :string},
              sources: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    source: {type: :string},
                    unit: {type: :string},
                    years: {type: :array, items: {type: :number}},
                    data_source: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          year: {type: :number},
                          value: {type: :number},
                          layer_info: {type: :string, nullable: true},
                          layer_link: {type: :string, nullable: true},
                          download_link: {type: :string, nullable: true}
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          sites_filters: {
            type: :object,
            properties: {
              organization: {type: :array, items: {type: :string}},
              intervention_type: {type: :array, items: {type: :string}},
              cause_of_decline: {type: :array, items: {type: :string}},
              ecological_aim: {type: :array, items: {type: :string}},
              socioeconomic_aim: {type: :array, items: {type: :string}},
              community_activities: {type: :array, items: {type: :string}}
            }
          },
          sites: {
            type: :object,
            properties: {
              id: {type: :integer},
              site_name: {type: :string},
              landscape_id: {type: :integer},
              landscape_name: {type: :string},
              site_area: {type: :string},
              site_centroid: {type: :string}
            }
          },
          flood_protection: {
            type: :object,
            properties: {
              indicator: {type: :string},
              period: {type: :string},
              value: {type: :number, nullable: true}
            }
          },
          fishery: {
            type: :object,
            properties: {
              indicator: {type: :string},
              year: {type: :number},
              value: {type: :number},
              category: {type: :string}
            }
          },
          ecoregion: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              category: {type: :string}
            }
          },
          file_converter: {
            type: :object,
            properties: {
              type: {type: :string},
              features: {
                type: :array,
                items: {type: :object},
                nullable: false
              }
            },
            required: [:type, :features]
          },
          location_resource: {
            type: :object,
            properties: {
              name: {type: :string},
              description: {type: :string, nullable: true},
              link: {type: :string, nullable: true}
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json
end

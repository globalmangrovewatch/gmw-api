# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v2/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'API docs',
        version: 'v2'
      },
      paths: {},
      servers: [
        {
          url: 'https://mangrove-atlas-api-staging.herokuapp.com',
          description: 'staging api url'
        },
        {
          url: 'https://mangrove-atlas-api.herokuapp.com',
          description: 'production api url'
        }
      ],
      components: {
        schemas: {
          metadata: {
            type: :object,
            properties: {
              location_id: {type: :string, nullable: true},
              units: {type: :string, nullable: true},
              years: {
                type: :array, 
                items: {type: :number}, 
                nullable: true
              },
              note: {type: :string, nullable: true}
            },
            required: [:unit, :note]
          },
          error_response: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  message: {type: :string, nullable: true}
                },
              },
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
                required:[]
              },
              medicareRequested: {type: :boolean},
              compensationUsdCents: {type: :integer,
                                     description: 'compensation'},
            },
            required: []
          },
          location_v2: {
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
                required:[]
              },
              medicareRequested: {type: :boolean},
              compensationUsdCents: {type: :integer,
                                     description: 'compensation'},
            },
            required: []
          },
          protected_areas: {
            type: :object,
            properties: {
              id: {type: :string},
              year: {type: :string},
              total_area: {type: :string},
              protected_area: {type: :string},
            },
            required: []
          },
          biodiversity: {
            type: :object,
            properties: {
              total: {type: :string},
              threatened: {type: :string},
              categories: {
                type: :object,
                properties: {
                  cr: {type: :string, nullable: true},
                  en: {type: :string, nullable: true},
                  nt: {type: :string, nullable: true},
                  lc: {type: :string, nullable: true}
                },
              },
            },
            required: [:total, :threatened, :categories]
          },
          restoration_potential: {
            type: :object,
            properties: {
              restoration_potential_score: {type: :number},
              restorable_area: {type: :number},
              restorable_area_perc: {type: :number},
              mangrove_area_extent: {type: :number},
            },
            required: [:restoration_potential_score, :restorable_area, :restorable_area_perc, :mangrove_area_extent]
          },
          degradation_and_loss: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
              },
            required: [:indicator, :value]
          },
          blue_carbon_investment: {
            type: :object,
            properties: {
              category: {type: :string},
              value: {type: :number},
              percentage: {type: :number},
              text: {type: :string},
            },
            required: [:category, :value, :percentage, :text]
          },
        international_status: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :string},
            },
            required: [:indicator, :value]
          },
          ecosystem_service: {
            type: :object,
            properties: {
              indicator: {type: :string},
              value: {type: :number},
            },
            required: [:indicator, :value]
          }
        },
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json
end

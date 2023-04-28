require "swagger_helper"

RSpec.describe "API V2 Locations", type: :request do
  path "/api/v2/locations" do
    get "Retrieves the data for the biodiversity widget" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :string

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

    # post 'Creates a new location' do
    #     tags 'Locations'
    #     consumes 'application/json'
    #     produces 'application/json'

    #     response 200, 'Ok' do
    #         schema type: :object,
    #         properties: {
    #             id: { type: :integer },
    #             title: { type: :string },
    #             content: { type: :string }
    #         },
    #         required: [ 'id', 'title', 'content' ]
    #     end
    #     response 404, 'blog not found' do
    #         example 'application/json', :example_key, {
    #             error: 'Not found'
    #           }
    #     end
    # end
  end
  path "/api/v2/locations/{location_id}", type: :request do
    get "Retrieves the data for the biodiversity widget" do
      tags "Locations"
      consumes "application/json"
      produces "application/json"
      parameter name: :location_id, in: :path, type: :string

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

    # put 'Updates the data  of a location' do
    #     tags 'Locations'
    #     consumes 'application/json'
    #     produces 'application/json'
    #     parameter name: :location_id, in: :path, type: :string
    #     response 200, 'Ok' do
    #         example 'application/json', :example_key, {
    #             id: 1,
    #             title: 'Hello world!',
    #             content: '...'
    #           }
    #     end
    #     response 404, 'error' do
    #         example 'application/json', :example_key, {
    #             error: 'Not found'
    #           }
    #     end
    # end

    # delete 'Deletes a location' do
    #     tags 'Locations'
    #     consumes 'application/json'
    #     produces 'application/json'
    #     parameter name: :location_id, in: :path, type: :string
    #     response 200, 'Ok' do
    #         example 'application/json', :example_key, {
    #             id: 1,
    #             title: 'Hello world!',
    #             content: '...'
    #           }
    #     end
    #     response 404, 'error' do
    #         example 'application/json', :example_key, {
    #             error: 'Not found'
    #           }
    #     end
    # end
  end
end

require 'swagger_helper'

RSpec.describe 'api/v2/widgets', type: :request do

    path '/api/v2/widgets/protected-areas' do
        get 'Retrieves the data for the protected area widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            parameter name: :units, in: :query, type: :string, enum: ['km2', 'ha', 'm']
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/protected_areas'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end

        # post 'Uploads the data for Protected areas' do
        #     tags 'Widgets'
        #     consumes 'application/json'
        #     produces 'application/json'
        #     parameter name: :widget, in: :body, schema: {
        #         type: :object,
        #         properties: {
        #             name: { type: :string },
        #             description: { type: :string },
        #             price: { type: :number },
        #             image: { type: :string }
        #         },
        #         required: ['name', 'description', 'price', 'image']
        #     }
        #     response 200, 'blog found' do
        #         example 'application/json', :example_key, {
        #             id: 1,
        #             title: 'Hello world!',
        #             content: '...'
        #           }
        #     end
        #     response 404, 'blog not found' do
        #         example 'application/json', :example_key, {
        #             error: 'Not found'
        #           }
        #     end
        # end
    end

    path '/api/v2/widgets/biodiversity' do
        get 'Retrieves the data for the biodiversity widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                    type: :object,
                    '$ref' => '#/components/schemas/biodiversity'
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata'
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/restoration-potential' do
        get 'Retrieves the data for the restoration potential chart' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            parameter name: :year, in: :query, type: :integer
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :object,
                        '$ref' => '#/components/schemas/restoration_potential'
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/degradation-and-loss' do
        get 'Retrieves the data for the degradation and loss Treemap chart' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            parameter name: :year, in: :query, type: :integer
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/degradation_and_loss'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/blue-carbon-investment' do
        get 'Retrieves the data for the blue carbon investment chart' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            parameter name: :year, in: :query, type: :integer
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/blue_carbon_investment'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/international_status' do
        get 'Retrieves the data for the international status widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/international_status'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/ecosystem_services' do
        get 'Retrieves the data for the ecosystem services widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/ecosystem_service'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/habitat_extent' do
        get 'Retrieves the data for the habitat extent widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/habitat_extent'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/net_change' do
        get 'Retrieves the data for the net change widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/net_change'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/aboveground_biomass' do
        get 'Retrieves the data for the aboveground_biomass widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/aboveground_biomass'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/tree_height' do
        get 'Retrieves the data for the tree height widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/tree_height'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end

    path '/api/v2/widgets/blue_carbon' do
        get 'Retrieves the data for the blue carbon widget' do
            tags 'Widgets'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :location_id, in: :query, type: :string
            
            response 200, 'Success' do
                schema type: :object,
                properties:{
                    data:{
                        type: :array,
                        items: {'$ref' => '#/components/schemas/blue_carbon'}
                    },
                    metadata: {
                        type: :object, 
                        '$ref' => '#/components/schemas/metadata' 
                    }
                }
                example 'application/json', :example_key, {
                    data: [{

                    }],
                    metadata: {
                        location_id: '1',
                    }
                }
            end

            response 500, 'Error 500' do
                schema type: :object,
                '$ref' => '#/components/schemas/error_response' 

                example 'application/json', :example_key, {
                    
                        location_id: '1',
                }
            end
        end
    end
   
end

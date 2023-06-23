require 'swagger_helper'

RSpec.describe 'v2/report', type: :request do

  path '/api/v2/report/answers' do

    get('answers report') do
      tags "report"
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v2/report/answers/{site_id}' do
    # You'll want to customize the parameter types...
    parameter name: 'site_id', in: :path, type: :string, description: 'site_id'

    get('answers_by_site report') do
      tags "report"
      response(200, 'successful') do
        let(:site_id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v2/report/answers_as_xlsx' do

    get('answers_as_xlsx report') do
      tags "report"
      produces "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      parameter name: "site_id", in: :query, required: false, type: :integer, description: "Site id"
      parameter name: "organization_id", in: :query, required: false, type: :integer, description: "Organization id"
      parameter name: "public_only", in: :query, required: false, schema: {type: :boolean, default: true}, description: "If true, retrieve only answers marked as public."
      response(200, 'successful') do
        description "An excel (xlsx) file."
        schema type: :file,
          properties: {
          }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end

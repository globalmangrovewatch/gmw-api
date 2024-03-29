require "swagger_helper"

RSpec.describe "v2/report", type: :request do
  path "/api/v2/report/answers" do
    get("answers report") do
      tags "Report"
      response(200, "successful") do
        before { skip }
        run_test!
      end
    end
  end

  path "/api/v2/report/answers/{site_id}" do
    # You'll want to customize the parameter types...
    parameter name: "site_id", in: :path, type: :string, description: "site_id"

    get("answers_by_site report") do
      tags "Report"
      response(200, "successful") do
        let(:site_id) { "123" }
        before { skip }
        run_test!
      end
    end
  end

  path "/api/v2/report/answers_as_xlsx" do
    get("answers_as_xlsx report") do
      tags "Report"
      produces "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      parameter name: "site_id", in: :query, required: false, type: :integer, description: "Site id"
      parameter name: "organization_id", in: :query, required: false, type: :integer, description: "Organization id"
      parameter name: "public_only", in: :query, required: false, schema: {type: :boolean, default: true}, description: "If true, retrieve only answers marked as public."
      response(200, "successful") do
        description "An excel (xlsx) file."
        schema type: :file,
          properties: {}
        before { skip }
        run_test!
      end
    end
  end

  path "/api/v2/report/answers_as_pdf/:site_id" do
    get("answers_as_pdf report") do
      tags "Report"
      produces "application/pdf"
      parameter name: "site_id", in: :path, required: true, type: :integer, description: "Site id"
      parameter name: "public_only", in: :query, required: false, schema: {type: :boolean, default: true}, description: "If true, retrieve only answers marked as public."
      response(200, "successful") do
        description "A pdf file."
        schema type: :file,
          properties: {}
        before { skip }
        run_test!
      end
    end
  end
end

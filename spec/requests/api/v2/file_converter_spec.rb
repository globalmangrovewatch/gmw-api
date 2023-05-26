require "swagger_helper"

RSpec.describe "API V2 File Converter", type: :request do
  path "/api/v2/spatial_file/converter" do
    post "Converts a geospatial format into a valid geojson" do
      tags "file_converter"
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, type: :file, required: true
      response 200, "Success" do
        schema type: :object,
          properties: {
            data: {
              :type => :object,
              "$ref" => "#/components/schemas/file_converter"
            }
          }

        context "when geojson file is provided", generate_swagger_example: true do
          let(:file) { fixture_file_upload "dummy_geojson.json" }

          run_test!
        end

        context "when zipfile is provided" do
          let(:file) { fixture_file_upload "zip_with_geojson.zip" }

          run_test!
        end

        context "when shapefile is provided" do
          let(:file) { fixture_file_upload "shapefile.zip" }

          run_test!

          context "when shapefile has spaces" do
            let(:file) { fixture_file_upload "shapefile_with_spaces.zip" }

            run_test!
          end
        end

        context "when gpkg file is provided" do
          let(:geojson_file) { Tempfile.new }
          let(:file) { fixture_file_upload "dummy_geopackage.gpkg" }

          before do
            geojson_file.write file_fixture("dummy_geojson.json").read
            geojson_file.rewind
            allow_any_instance_of(FileDataImport::Parser::Gpkg).to receive(:convert_to_geojson)
            allow_any_instance_of(FileDataImport::Parser::Gpkg).to receive(:path_to_geojson_file).and_return(geojson_file.path)
          end

          after do
            geojson_file.close
            geojson_file.unlink
          end

          run_test!
        end
      end

      response 400, "Bad Request" do
        let(:file) { fixture_file_upload "invalid_file.txt" }

        run_test!
      end
    end
  end
end

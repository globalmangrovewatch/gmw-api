# frozen_string_literal: true

module FileDataImport
  module Parser
    class Shp < FileDataImport::Parser::Base
      def convert_to_geojson
        `ogr2ogr -f GeoJSON #{path_to_geojson_file} #{path_to_file}`
      end

      def path_to_geojson_file
        @path_to_geojson_file ||= path_to_file.gsub(File.extname(path_to_file), ".geojson")
      end

      def feature_collection
        convert_to_geojson
        @features ||= JSON.parse(File.read(path_to_geojson_file)) || {}
      end
    end
  end
end

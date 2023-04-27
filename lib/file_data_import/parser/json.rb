# frozen_string_literal: true

module FileDataImport
  module Parser
    class Json < FileDataImport::Parser::Base
      def feature_collection
        @features ||= JSON.parse(File.read(path_to_file)) || {}
        if !@features.key?("type") || (@features["type"] != "FeatureCollection")
          raise StandardError.new "Invalid GeoJSON file."
        end
        @features
      end
    end
  end
end

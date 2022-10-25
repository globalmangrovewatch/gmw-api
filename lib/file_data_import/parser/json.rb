# frozen_string_literal: true

module FileDataImport
  module Parser
    class Json < FileDataImport::Parser::Base

      def feature_collection
        @features ||= JSON.parse(File.read(path_to_file)) || {}
        if not @features.key?("type") or @features['type'] != 'FeatureCollection'
            raise Exception.new "Invalid GeoJSON file."
        end
        return @features
      end
    end
  end
end

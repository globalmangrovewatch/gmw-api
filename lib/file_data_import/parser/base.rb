# frozen_string_literal: true

module FileDataImport
  module Parser
    class Base
      AVAILABLE_EXTENSIONS = %w[zip shp gpkg json geojson].freeze

      attr_reader :path_to_file

      def initialize(path_to_file)
        @path_to_file = path_to_file
      end

      def feature_collection
        raise NotImplementedError, "You need to implement foreach_with_line method."
      end
      
      def clean_up
        raise NotImplementedError, "You need to implement clean_up method."
      end
    end
  end
end

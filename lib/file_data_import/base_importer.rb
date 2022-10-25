# frozen_string_literal: true

module FileDataImport
  class BaseImporter
    class InvalidImporterError < NameError; end
    class InvalidParserError < NameError; end

    attr_reader :file, :results

    def initialize(file)
      @file = file
      @results = {}
    end

    def convert
      @results = parser.feature_collection || {}
    end

    protected

    def parser
      @parser ||= begin
        extension_value = extension.capitalize
        if extension_value == 'Geojson'
          extension_value = 'Json'
        end
        
        parser_name = "FileDataImport::Parser::#{extension_value}"
        parser_name.constantize.new(file.path)
                  rescue NameError
                    raise InvalidParserError, "Undefined parser #{parser_name}."
      end
    end

    def extension
      @extension ||= File.extname(basename)[1..-1]
    end

    def basename
      @basename ||= file.original_filename
    end
  end
end

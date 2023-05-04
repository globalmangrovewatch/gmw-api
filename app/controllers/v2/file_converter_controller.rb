class V2::FileConverterController < ApiController
  include FileDataImport
  MAX_FILE_SIZE = 20000000
  # POST /spatial_file/converter
  def convert
    file = import_params[:file]
    @response = if file.blank? || file.size > MAX_FILE_SIZE
      exception("File must exist and be smaller than #{MAX_FILE_SIZE / 1000000} MB")
    else
      importer.convert
    end
  end

  private

  def import_params
    params.permit(:file, :format)
  end

  def importer
    @importer ||= FileDataImport::BaseImporter.new(import_params[:file])
  end
end

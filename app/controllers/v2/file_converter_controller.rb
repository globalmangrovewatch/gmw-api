class V2::FileConverterController < ApiController

    # POST /locations/:id
    def import
        file = params['file']
        response = if file.blank? || file.size > MAX_FILE_SIZE
            { errors: "File must exist and be smaller than #{MAX_FILE_SIZE/1000} KB" }
          else
            Fmu.file_upload(file)
        end
    end

    private
        def import_params
        params.permit(:file)
        end

end
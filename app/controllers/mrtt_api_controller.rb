class MrttApiController < ActionController::API
    before_action :authenticate_user!
    rescue_from Exception, with: :exception
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique
  
    protected
      def exception(exception)
        render json: { "error": exception }, status: :bad_request
      end
      
      def record_not_unique(exception)
        value = exception.message.split(")=(")[1].split(")")[0]
        render json: { "error": "Unique constraint violation. '%s' already exists." % [value] }, status: :unprocessable_entity
      end

      def record_not_found(exception)
        render json: { "error": exception.message }, status: :not_found
      end
end

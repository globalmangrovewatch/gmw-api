class MrttApiController < ActionController::API
    before_action :authenticate_user!, :log_current_user
    rescue_from Exception, with: :exception
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique
  
    protected
      def exception(exception)
        render json: { "error": exception }, status: :bad_request
      end
      
      def record_not_unique(exception)
        value = exception.message.split(")=(")[1].split(")")[0]
        render json: { "error": "'%s' already exists." % [value] }, status: :unprocessable_entity
      end

      def record_not_found(exception)
        render json: { "error": "Record not found" }, status: :not_found
      end

      def insufficient_privilege
        render json: {message: "Insufficient privilege" }, status: :unauthorized
      end

      def log_current_user
        current_user_id = current_user.id
        roles = current_user.roles
        puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        puts "xxx current_user.id: %s" % current_user_id
        puts "xxx current_user.roles: %s" % roles
        puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      end
end

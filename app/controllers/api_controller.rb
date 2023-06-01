class ApiController < ActionController::API
  rescue_from Exception, with: :exception

  def exception(exception)
    puts exception
    render json: {error: exception}, status: :bad_request
  end
end

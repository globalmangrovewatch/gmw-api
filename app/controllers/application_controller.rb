class ApplicationController < ActionController::Base
  # include Response
  # include ExceptionHandler
  skip_before_action :verify_authenticity_token, only: [:cors_preflight]

  def cors_preflight
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
    response.headers['Access-Control-Max-Age'] = '1728000'
    head :ok
  end
end

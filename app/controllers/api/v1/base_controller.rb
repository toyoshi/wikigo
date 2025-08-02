class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_api_user
  before_action :set_default_format
  
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  
  protected
  
  def authenticate_api_user
    authenticate_or_request_with_http_token do |token, options|
      @current_api_token = ApiToken.find_by_token(token)
      if @current_api_token && !@current_api_token.expired?
        @current_api_token.touch_last_used!
        @current_user = @current_api_token.user
        true
      else
        false
      end
    end
  end
  
  def current_user
    @current_user
  end
  
  def current_api_token
    @current_api_token
  end
  
  def set_default_format
    request.format = :json unless params[:format]
  end
  
  # Error handlers
  def render_not_found(exception = nil)
    render json: {
      error: 'Not Found',
      message: exception&.message || 'The requested resource was not found'
    }, status: :not_found
  end
  
  def render_parameter_missing(exception)
    render json: {
      error: 'Parameter Missing',
      message: exception.message
    }, status: :bad_request
  end
  
  def render_unprocessable_entity(exception)
    render json: {
      error: 'Validation Failed',
      message: exception.message,
      details: exception.record&.errors&.full_messages
    }, status: :unprocessable_entity
  end
  
  def render_unauthorized(message = 'Invalid or missing API token')
    render json: {
      error: 'Unauthorized',
      message: message
    }, status: :unauthorized
  end
  
  def render_forbidden(message = 'Access denied')
    render json: {
      error: 'Forbidden',
      message: message
    }, status: :forbidden
  end
end
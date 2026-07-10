class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_api_user
  before_action :set_default_format
  before_action :set_host
  
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

  # Overrides ActionController::HttpAuthentication::Token::ControllerMethods.
  # By default this renders a plain-text "HTTP Token: Access denied." body,
  # which does not match the JSON error format documented for the API
  # (see WikiGo-REST-API-Documentation.md, Authentication Errors). Render the
  # documented JSON error instead so API clients can reliably parse 401s.
  def request_http_token_authentication(realm = "Application", message = nil)
    render_unauthorized(message || 'Invalid or missing API token')
  end
  
  def set_default_format
    request.format = :json unless params[:format]
  end

  # ActionController::API (unlike ApplicationController) does not configure
  # default_url_options[:host], so any code that generates full URLs (e.g.
  # Webhooks::Send#call, which builds root_url) blows up with
  # "ArgumentError: Missing host to link to!" when invoked from the API
  # (see Words::Create/Words::Update, triggered by create/update). Mirror
  # ApplicationController#set_host so URL helpers work from API requests too.
  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
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
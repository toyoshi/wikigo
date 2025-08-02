class ApiTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :authenthicate_admin!

  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @new_api_token = session.delete(:new_api_token)
  end

  def create
    begin
      name = token_params[:name].present? ? token_params[:name] : "Default API Key"
      token, plain_token = current_user.generate_api_token(name)
      session[:new_api_token] = plain_token
      redirect_to api_tokens_path, notice: 'API token generated successfully'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to api_tokens_path, alert: "Error creating token: #{e.message}"
    end
  end

  def destroy
    @token = current_user.api_tokens.find(params[:id])
    @token.destroy
    redirect_to api_tokens_path, notice: 'API token deleted successfully'
  end

  private

  def token_params
    params.permit(:name)
  end
end
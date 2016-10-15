class Users::RegistrationsController < Devise::RegistrationsController
  before_action :token_valid?, only: [:new, :create]

  protected

  def token_valid?
    token = params[:registraion_token] || cookies[:registraion_token]
    if token == Option.get(:USER_REGISTRATION_TOKEN)
      cookies[:registraion_token] = token
    else
      redirect_to root_path, flash_message: 'invalid token' 
    end
  end
end

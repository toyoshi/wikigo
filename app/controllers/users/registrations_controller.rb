class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_registable, only: [:new, :create]

  protected

  def check_registable
    #Is first user
    return true if User.count == 0

    #TOKEN is valid
    token = params[:registration_token] || cookies[:registration_token]
    if token == Option.get(:USER_REGISTRATION_TOKEN)
      cookies[:registration_token] = token
    else
      redirect_to root_path, notice: 'invalid token' 
    end
  end
end

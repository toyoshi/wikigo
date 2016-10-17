class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_registable, only: [:new, :create]

  protected

  def check_registable
    #Is first user
    return true if User.count == 0

    #TOKEN is valid
    token = params[:rt] || cookies[:rt]
    if token == Option.user_registration_token
      cookies[:rt] = token
    else
      redirect_to root_path, notice: 'invalid token' 
    end
  end
end

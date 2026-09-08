class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_registable, only: [:new, :create]

  protected

  def check_registable
    #Is first user
    return true if User.count == 0

    #TOKEN is valid
    # Fail closed if the invitation token has not been configured.
    configured_token = Option.user_registration_token.to_s
    token = (params[:rt] || session[:rt]).to_s
    if configured_token.present? &&
        token.present? &&
        ActiveSupport::SecurityUtils.secure_compare(token, configured_token)
      session[:rt] = token
    else
      redirect_to root_path, notice: 'Registration is invitation-only. Please use the invitation URL provided by an admin.'
    end
  end
end

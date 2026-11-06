class Users::RegistrationsController < ApplicationController
  include Authentication

  # #110: was Devise::RegistrationsController. The invitation-token gate is
  # this app's own logic and stays; account creation now rides
  # has_secure_password (password + password_confirmation) and the app's own
  # Session records — no Warden in the sign-up path.
  before_action :check_registable, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: 'Welcome! Your account was created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      # Changing the password invalidates existing sessions, same as the
      # password-reset flow. (This user's own new password was just set, so
      # they sign in again — acceptable for a profile password change.)
      @user.sessions.destroy_all if @user.previous_changes["password_digest"].present?
      redirect_to root_path, notice: 'Your profile was updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def check_registable
      # Is first user
      return true if User.count == 0

      # TOKEN is valid
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

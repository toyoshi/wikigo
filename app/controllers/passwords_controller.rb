class PasswordsController < ApplicationController
  include Authentication

  before_action :set_user_by_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    # Existence-blind on purpose: same redirect either way, no user-enumeration
    # oracle. Delivery is queued like every other outbound mail.
    if user = User.find_by(email: params[:email])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_user_session_path, notice: "Password reset instructions sent (if an account with that email exists)."
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_user_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end

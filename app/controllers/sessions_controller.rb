class SessionsController < ApplicationController
  include Authentication

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_session_path, alert: "Try again later." }

  def new
  end

  def create
    # User.authenticate matches username or email case-insensitively and
    # verifies the password against the BCrypt digest (#110).
    if user = User.authenticate(login: params[:login], password: params[:password])
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_user_session_path, alert: "Try another username or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_user_session_path, status: :see_other
  end
end

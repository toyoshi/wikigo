class ApplicationController < ActionController::Base
  # Resumes the server-side Session from the signed session_id cookie on
  # every request (warden's job under Devise). Enforcement stays explicit —
  # controllers gate with authenticate_user! like they gated with Devise's
  # authenticate_user! — so the forced require_authentication callback itself
  # is skipped application-wide.
  include Authentication

  include HostConfiguration

  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit, :select_theme, :set_search_obj
  before_action :set_host

  helper_method :current_user, :user_signed_in?

  # #110: Devise's warden helpers are gone; the authentication-generator
  # pattern reads the Current session (set from the signed session_id cookie
  # by the Authentication concern used by the auth controllers). Pages are
  # public by default; controllers that need a user call authenticate_user!
  # the same way they used Devise's authenticate_user! before.
  def current_user
    Current.session&.user
  end

  def user_signed_in?
    Current.session.present?
  end

  def authenticate_user!
    # The Authentication concern's flow: resume or stash-then-redirect.
    require_authentication
  end

  def authenthicate_admin!
    authenticate_user! unless user_signed_in?
    raise 'Only Admin allowed access' unless current_user&.admin?
  end

  def select_theme
    return unless current_theme
    prepend_view_path "#{Rails.root}/public/themes/#{current_theme}/views/"
  end

  # Used for search by ransack gem
  def set_search_obj
    @search = Word.ransack(params[:q])
  end

  protected

  def current_theme
    Option.theme
  end
end

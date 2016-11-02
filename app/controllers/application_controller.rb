class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit, :select_theme, :set_search_obj
  before_action :configure_permitted_parameters, if: :devise_controller?


  def authenthicate_admin!
    raise 'Only Admin allowed access' unless current_user.admin?
  end

  def select_theme
    return unless current_theme
    prepend_view_path "#{Rails.root}/public/themes/#{current_theme}/views/"
  end

  # Used for search by ransack gem
  def set_search_obj
    @search = Word.search(params[:q])
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def current_theme
    Option.theme
  end
end

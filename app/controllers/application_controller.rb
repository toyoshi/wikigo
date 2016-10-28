class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit, :select_theme

  def authenthicate_admin!
    raise 'Only Admin allowed access' unless current_user.admin?
  end

  def select_theme
    return unless current_theme
    prepend_view_path "#{Rails.root}/public/themes/#{current_theme}/views/"
  end

  private

  def current_theme
    Option.theme
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit

  def authenthicate_admin!
    raise 'Only Admin allowed access' unless current_user.admin?
  end
end

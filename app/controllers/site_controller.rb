class SiteController < ApplicationController
  def members
    @key = Option.user_registration_token
  end

  def regenerate_token
    Option.update_registration_token
    redirect_to site_members_path, notice: 'Token regenerated'
  end
end

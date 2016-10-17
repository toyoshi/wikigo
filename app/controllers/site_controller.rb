class SiteController < ApplicationController
  def members
    @key = Option.get(:USER_REGISTRATION_TOKEN)
  end

  def regenerate_token
    Option.update_registration_token
    redirect_to site_members_path, notice: 'Token regenerated'
  end
end

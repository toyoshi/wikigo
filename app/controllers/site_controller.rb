class SiteController < ApplicationController
  def members
    @key = Option.get(:USER_REGISTRATION_TOKEN)
  end
end

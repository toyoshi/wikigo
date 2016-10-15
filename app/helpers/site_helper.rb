module SiteHelper
  def invitation_url(key)
    url_for(controller: 'users/registrations', action: :new, registration_token: key, only_path: false)
  end
end

module ApplicationHelper
  def site_title
    Option.site_title
  end

  def settings?
    path = request.path_info
    path =~ %r{^/settings} && current_user
  end

  def self.root_url_with_protocol
    root_url(only_path: false)
  end
end

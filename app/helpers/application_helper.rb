module ApplicationHelper
  def site_title
    Option.site_title
  end

  def settings?
    request.path_info =~ %r{^/settings}
  end

  def self.root_url_with_protocol
    root_url(only_path: false)
  end
end

module ApplicationHelper
  def site_title
    Option.site_title
  end

  def self.root_url_with_protocol
    root_url(only_path: false)
  end
end

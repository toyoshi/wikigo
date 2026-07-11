# Shared host configuration for URL generation.
#
# Both the HTML stack (ApplicationController) and the API stack
# (Api::V1::BaseController, an ActionController::API subclass) need to stash
# the current request's host on Rails.application.routes.default_url_options so
# that code generating absolute URLs (e.g. Webhooks::Send#call building
# root_url) works. ActionController::API does not inherit ApplicationController,
# so the logic lived in two places; this concern is the single source of truth.
module HostConfiguration
  extend ActiveSupport::Concern

  private

  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end
end

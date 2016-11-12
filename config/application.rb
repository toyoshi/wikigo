require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wikigo
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/services)
  end
end

source 'https://rubygems.org'

gem 'rails', '~> 6.0'
gem 'nokogiri', force_ruby_platform: true
gem 'bootsnap', require: false
gem 'puma'
gem 'concurrent-ruby', '1.3.4'
gem 'mini_racer' # Modern V8 JS engine, replacement for therubyracer
gem 'sass-rails', '~> 6.0' # SCSS support for Rails 6 with Ruby 2.7
gem 'uglifier', '~> 4.2' # JS minification compatible with Ruby 2.7
gem 'coffee-rails', '~> 4.2' # CoffeeScript support for Rails 6
gem 'jquery-rails', '~> 4.4' # jQuery for Rails 6 compatibility
gem 'jquery-ui-rails' # jQuery UI components
gem 'turbolinks'
gem 'jbuilder'

gem 'webpacker', '~> 5.4' # Webpack for Rails 6 (stable version)

gem 'gon'
gem 'rubyzip'

gem 'devise'
gem 'slim-rails'
gem 'honoka-rails'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'diffy'
gem 'kaminari'

# gem 'cloudinary' # Cloud image service - may have JS dependencies

gem 'acts-as-taggable-on'
gem 'ransack', '~> 2.4.1' # Ruby 2.7 compatibility

gem 'public_activity', '~> 2.0' # For Ruby 2.7 compatibility
gem 'acts_as_favable', github: 'toyoshi/acts_as_favable' # May have compatibility issues

gem 'faraday'
gem 'rails-i18n', '~> 6.0'


group :development, :test do
  gem 'byebug', platform: :mri
end


group :development do
  gem 'sqlite3'
  # gem 'web-console' # May have JS dependencies
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  # gem 'rubocop', require: false # Development tool - not essential for server
  # gem 'pry-rails' # Debug tool - not essential for server
  # gem 'pry-doc' # Debug tool - not essential for server  
  # gem 'pry-byebug' # Debug tool - not essential for server
  # gem 'pry-stack_explorer' # Debug tool - not essential for server

  # gem 'better_errors' # May have JS dependencies
  # gem 'binding_of_caller' # Debug tool - not essential for server

  # gem 'guard' # File watcher - may have JS dependencies
  # gem 'guard-minitest' # Test runner - not essential for server

  gem 'dotenv-rails'
  # gem 'i18n_generators' # Generator - not essential for server
end

group :test do
end

group :production do
  gem 'pg'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

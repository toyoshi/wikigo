source 'https://rubygems.org'

gem 'rails', '~> 8.0'
gem 'propshaft' # Rails 8 default asset pipeline
gem 'importmap-rails' # ES6 modules via import maps
gem 'turbo-rails' # Hotwire's SPA-like page accelerator
gem 'stimulus-rails' # Hotwire's modest JavaScript framework

gem 'solid_cache' # Database-backed ActiveSupport::Cache::Store
# gem 'solid_queue' # Removed - switched to synchronous webhook processing
gem 'solid_cable' # Database-backed ActionCable backend - required in Rails 8

gem 'nokogiri'
gem 'image_processing', '~> 1.2'
gem 'bootstrap', '~> 5.3'
gem 'dartsass-rails', '~> 0.5'
gem 'bootsnap', require: false
gem 'puma'
gem 'jbuilder'

gem 'gon'
gem 'rubyzip'

gem 'devise'
gem 'slim-rails'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'diffy'
gem 'kaminari'


gem 'acts-as-taggable-on'
gem 'ransack' # Latest version for Ruby 3.2 and Rails 8

gem 'public_activity' # Latest version for Ruby 3.2 compatibility
gem 'acts_as_favable', github: 'toyoshi/acts_as_favable'

gem 'faraday'
gem 'rails-i18n', '~> 8.0'


group :development, :test do
  gem 'byebug', platform: :mri
end


group :development do
  gem 'sqlite3', '~> 2.0'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'dotenv-rails'
end

group :test do
end

group :production do
  gem 'pg'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

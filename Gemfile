source 'https://rubygems.org'
source 'https://rails-assets.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.5'
# Use pg as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use puma as the app server
gem 'puma'

# Use Foreman to manage the app
gem 'foreman'

group :development do
  # utilities
  gem 'letter_opener'

  # Use Capistrano for deployment
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
end

# Use debugger
# gem 'debugger', group: [:development, :test]

# development and test
group :development, :test do
  # specs
  gem 'rspec-rails'
  gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'ffaker'
  gem 'coveralls', require: false

  # utilities
  gem 'annotate', github: 'razum2um/annotate_models', branch: 'develop' # using alternative repo since original repo doesn't work with 4.1
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'database_cleaner'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-sidekiq'
  gem 'guard-spork'
  gem 'spork-rails'
end

# auth
gem 'devise'
gem 'cancancan'
gem 'omniauth'
gem 'omniauth-facebook'

# admin
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'rails_admin'

# models
gem 'friendly_id', '~> 5.0.0'
gem 'workflow', github: 'geekq/workflow'
gem 'dragonfly', '~> 1.0.4'
gem 'enumerize'
gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'impressionist'
gem 'paper_trail', '~> 3.0.0'
gem 'ancestry'
gem 'acts_as_list'
gem 'active_model_serializers'

# views
gem 'slim'
gem 'haml-rails'
gem 'simple_form', '~> 3.1.0.rc1', github: 'plataformatec/simple_form'
gem 'eco'

# assets
gem 'bootstrap-sass', '~> 3.2.0'
gem 'bourbon'
gem 'rails-assets-fontawesome'
gem 'rails-assets-lodash'
gem 'rails-assets-query-string'
gem 'rails-assets-superagent'
gem 'rails-assets-vue'

# services
gem 'sinatra', '>= 1.3.0', require: false
gem 'doorkeeper', '~> 0.7.0'
gem 'pg_search'
gem 'countries', require: 'iso3166'
gem 'geocoder'

gem 'searchkick'

gem 'sidekiq', github: 'mperham/sidekiq'
gem 'sidetiq', github: 'tobiassvn/sidetiq'

gem 'redis-rails'
gem 'redis-objects'
gem 'redmon', require: false

gem 'rollbar' # rollbar error notification

# utilities
gem 'dotenv-rails'
gem 'pry-rails'
gem 'miro'
gem 'color'
gem 'colorscore'
gem 'httparty'
gem 'active_link_to'
gem 'meta-tags', require: 'meta_tags'
gem 'draper', github: 'jianyuan/draper'
gem 'redcarpet'

# rack
gem 'rack-cache', require: 'rack/cache', group: :production
gem 'rack-mini-profiler'

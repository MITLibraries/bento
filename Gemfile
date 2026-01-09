source 'https://rubygems.org'
ruby '3.4.8'

gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching', branch: 'master'
gem 'barnes'
gem 'bootsnap'
gem 'google-api-client'
gem 'http'
gem 'http_logger'
gem 'ipaddr_range_set'
gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'lograge'
gem 'mitlibraries-theme', git: 'https://github.com/mitlibraries/mitlibraries-theme', tag: 'v1.4'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'nokogiri'
gem 'puma'
gem 'rack-attack'
gem 'rails', '~> 7.2.0'
gem 'sass-rails'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'skylight'
gem 'stringex'
gem 'terser'

group :production do
  gem 'connection_pool', '< 3'   # 3.x requires keyword args; pin to 2.x for Rails 7.2.3
  gem 'dalli'
  gem 'pg'
end

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'dotenv-rails'
  gem 'listen'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'web-console'
end

group :test do
  gem 'climate_control'
  gem 'minitest',  '< 7' # required for Rails 7.2.3
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'vcr'
  gem 'webmock'
end

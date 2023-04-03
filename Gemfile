source 'https://rubygems.org'
ruby '3.1.2'

gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching', branch: 'master'
gem 'barnes'
gem 'bootsnap'
gem 'flipflop'
gem 'google-api-client'
gem 'http'
gem 'http_logger'
gem 'ipaddr_range_set'
gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'lograge'
gem 'mitlibraries-theme', git: 'https://github.com/mitlibraries/mitlibraries-theme', tag: 'v1.0.2'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'nokogiri'
gem 'puma'
gem 'rack-attack'
gem 'rails', '~> 7.0.0'
gem 'sass-rails'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'skylight'
gem 'stringex'
gem 'uglifier'

group :production do
  gem 'dalli'
  gem 'pg'
end

group :development, :test do
  gem 'pry-rails'
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
  gem 'minitest-rails'
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'vcr'
  gem 'webmock'
end

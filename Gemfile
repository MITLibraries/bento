source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '5.0.0.1'
gem 'devise'
gem 'google-api-client'
gem 'http'
gem 'http_logger'
gem 'jquery-rails'
gem 'less-rails'
gem 'omniauth-mit-oauth2'
gem 'omniauth-oauth2'
gem 'puma'
gem 'rollbar'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'dalli'
  gem 'memcachier'
  gem 'newrelic_rpm'
  gem 'pg'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'byebug'
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'rubocop'
  gem 'web-console'
end

group :test do
  gem 'coveralls', require: false
  gem 'minitest-reporters'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'vcr'
  gem 'webmock'
end

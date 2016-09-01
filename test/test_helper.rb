require 'simplecov'
require 'coveralls'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails/capybara'
require 'minitest/reporters'
Minitest::Reporters.use!

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    if interaction.request.headers['X-Authenticationtoken']
      interaction.request.headers['X-Authenticationtoken'].first
    end
  end
  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    if interaction.response.headers['X-Authenticationtoken']
      interaction.response.headers['X-Authenticationtoken'].first
    end
  end
  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    JSON.parse(interaction.response.body)['AuthToken']
  end

  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    if interaction.request.headers['X-Sessiontoken']
      interaction.request.headers['X-Sessiontoken'].first
    end
  end
  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    if interaction.response.headers['X-Sessiontoken']
      interaction.response.headers['X-Sessiontoken'].first
    end
  end
  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    JSON.parse(interaction.response.body)['SessionToken']
  end

  config.filter_sensitive_data('"UserId":"FAKE_EDS_USER_ID"') do
    "\"UserId\":\"#{ENV['EDS_USER_ID']}\""
  end
  config.filter_sensitive_data('"Password":"FAKE_EDS_PASSWORD"') do
    "\"Password\":\"#{ENV['EDS_PASSWORD']}\""
  end
  config.filter_sensitive_data('FAKE_GOOGLE_API_KEY') do
    (ENV['GOOGLE_API_KEY']).to_s
  end
  config.filter_sensitive_data('FAKE_GOOGLE_CUSTOM_SEARCH_ID') do
    (ENV['GOOGLE_CUSTOM_SEARCH_ID']).to_s
  end
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alpha order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionController
  class TestCase
    include Devise::Test::ControllerHelpers
  end
end

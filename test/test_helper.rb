require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/minitest'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  config.filter_sensitive_data('FAKE_KEY') do
    (ENV['ALEPH_KEY']).to_s
  end

  config.filter_sensitive_data('https://fake_server.example.com/rest-dlf/') do
    (ENV['ALEPH_API_URI']).to_s
  end

  config.filter_sensitive_data('http://fake_server.example.com/rest-dlf/') do
    (ENV['ALEPH_API_URI']).to_s.gsub('https', 'http')
  end

  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    interaction.request.headers['X-Authenticationtoken']&.first
  end
  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    interaction.response.headers['X-Authenticationtoken']&.first
  end
  config.filter_sensitive_data('FakeAuthenticationtoken') do |interaction|
    begin
      JSON.parse(interaction.response.body)['AuthToken']
    rescue JSON::ParserError
      false
    end
  end
  config.filter_sensitive_data('FAKE_WORLDCAT_KEY') do
    (ENV['WORLDCAT_API_KEY']).to_s
  end

  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    interaction.request.headers['X-Sessiontoken']&.first
  end
  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    interaction.response.headers['X-Sessiontoken']&.first
  end
  config.filter_sensitive_data('FakeSessiontoken') do |interaction|
    begin
      token = JSON.parse(interaction.response.body)['SessionToken']
      token&.tr('\\', '')
    rescue JSON::ParserError
      false
    end
  end

  config.filter_sensitive_data('"UserId":"FAKE_EDS_USER_ID"') do
    "\"UserId\":\"#{ENV['EDS_USER_ID']}\""
  end
  config.filter_sensitive_data('"Password":"FAKE_EDS_PASSWORD"') do
    "\"Password\":\"#{ENV['EDS_PASSWORD']}\""
  end
  config.filter_sensitive_data('FAKE_EDS_PROFILE') do
    (ENV['EDS_PROFILE']).to_s
  end
  config.filter_sensitive_data('FAKE_GOOGLE_API_KEY') do
    (ENV['GOOGLE_API_KEY']).to_s
  end
  config.filter_sensitive_data('FAKE_GOOGLE_CUSTOM_SEARCH_ID') do
    (ENV['GOOGLE_CUSTOM_SEARCH_ID']).to_s
  end

  # The only sensitive data here is the API key, but filtering these makes 
  # for less frequent cassette regeneration and thus less test suite maintenance.
  config.filter_sensitive_data('https://another_fake_server.example.com/v1') do
    (ENV['PRIMO_API_URL']).to_s
  end
  config.filter_sensitive_data('FAKE_PRIMO_API_KEY') do
    (ENV['PRIMO_API_KEY']).to_s
  end
  config.filter_sensitive_data('FAKE_PRIMO_VID') do
    (ENV['PRIMO_VID']).to_s
  end
  config.filter_sensitive_data('FAKE_PRIMO_TAB') do
    (ENV['PRIMO_TAB']).to_s
  end
  config.filter_sensitive_data('FAKE_PRIMO_BOOK_SCOPE') do
    (ENV['PRIMO_BOOK_SCOPE']).to_s
  end
  config.filter_sensitive_data('FAKE_PRIMO_ARTICLE_SCOPE') do
    (ENV['PRIMO_ARTICLE_SCOPE']).to_s
  end
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alpha order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

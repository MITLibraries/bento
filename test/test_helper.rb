require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = 'coverage.lcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/minitest'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock

  # Filter Google API credentials.
  config.filter_sensitive_data('FAKE_GOOGLE_API_KEY') do
    (ENV['GOOGLE_API_KEY']).to_s
  end
  config.filter_sensitive_data('FAKE_GOOGLE_CUSTOM_SEARCH_ID') do
    (ENV['GOOGLE_CUSTOM_SEARCH_ID']).to_s
  end

  # Filter Primo Search API credentials and params.
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

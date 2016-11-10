Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  ENV['EDS_URL'] = 'https://eds-api.ebscohost.com'
  ENV['EDS_USER_ID'] = 'FAKE_EDS_USER_ID'
  ENV['EDS_PASSWORD'] = 'FAKE_EDS_PASSWORD'
  ENV['EDS_NO_ALEPH_PROFILE'] = 'apinoaleph'
  ENV['EDS_ALEPH_PROFILE'] = 'apibarton'
  ENV['GOOGLE_API_KEY'] = 'FAKE_GOOGLE_API_KEY'
  ENV['GOOGLE_CUSTOM_SEARCH_ID'] = 'FAKE_GOOGLE_CUSTOM_SEARCH_ID'
  ENV['WORLDCAT_URI'] = 'http://www.worldcat.org/webservices/catalog/search/worldcat/'
  ENV['WORLDCAT_API_KEY'] = 'FAKE_WORLDCAT_KEY'
  ENV['ENABLED_BOXES'] = 'website,books,articles,worldcat'
  ENV['MAX_AUTHORS'] = '3'
  ENV['EDS_ALEPH_URI'] = 'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26profile%3Dedsbarton%26bquery%3D'
  ENV['EDS_NO_ALEPH_URI'] = 'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26site%3Dedsnoaleph%26profile%3Dedsnoaleph%26bquery%3D'

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

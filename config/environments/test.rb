require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  ENV['EDS_URL'] = 'https://eds-api.ebscohost.com'
  ENV['EDS_USER_ID'] = 'FAKE_EDS_USER_ID'
  ENV['EDS_PASSWORD'] = 'FAKE_EDS_PASSWORD'
  ENV['EDS_PROFILE'] = 'apiwhatnot'
  ENV['GOOGLE_API_KEY'] = 'FAKE_GOOGLE_API_KEY'
  ENV['GOOGLE_CUSTOM_SEARCH_ID'] = 'FAKE_GOOGLE_CUSTOM_SEARCH_ID'
  ENV['WORLDCAT_URI'] = 'http://www.worldcat.org/webservices/catalog/search/worldcat/'
  ENV['WORLDCAT_API_KEY'] = 'FAKE_WORLDCAT_KEY'
  ENV['ENABLED_BOXES'] = 'website,books,articles,worldcat'
  ENV['MAX_AUTHORS'] = '3'
  ENV['EDS_PROFILE_URI'] = 'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26site%3Dedswhatnot%26profile%3Dedswhatnot%26bquery%3D'
  ENV['EDS_BOOK_FACETS'] = '&facetfilter=1,SourceType:Books,SourceType:eBooks,SourceType:Audiobooks,SourceType:Dissertations,SourceType:Music+Scores,SourceType:Audio,SourceType:Videos'
  ENV['EDS_ARTICLE_FACETS'] = '&facetfilter=1,SourceType:Academic+Journals,SourceType:Magazines,SourceType:Conference+Materials'
  ENV['FEEDBACK_MAIL_TO'] = 'test@example.com'
  ENV['ALEPH_API_URI'] = 'https://fake_server.example.com/rest-dlf/'
  ENV['ALEPH_KEY'] = 'FAKE_KEY'
  ENV['PER_PAGE'] = '10'
  ENV['FLIPFLOP_KEY'] = 'yoyo'
  ENV['ALEPH_HINT_SOURCE'] = 'https://fake.example.com/s/fake/getserial_mini.xml?dl=1'
  ENV['FULL_RECORD_TOGGLE_BUTTON'] = 'true'

  ENV['PRIMO_SEARCH_API_URL'] = 'https://another_fake_server.example.com'
  ENV['PRIMO_SEARCH_API_KEY'] = 'FAKE_PRIMO_SEARCH_API_KEY'
  ENV['PRIMO_VID'] = 'FAKE_PRIMO_VID'
  ENV['PRIMO_BOOK_SCOPE'] = 'alma'
  ENV['PRIMO_ARTICLE_SCOPE'] = 'cdi'
  ENV['MIT_PRIMO_URL'] = 'https://mit.primo.exlibrisgroup.com'
  ENV['SYNDETICS_PRIMO_URL'] = 'https://syndetics.com/index.php?client=primo'

  ENV['SCAN_EXCLUSIONS']='Materials -- Standards -- United States -- Periodicals;Materials -- Standards -- United States -- Periodicals;Standards, Engineering;Standards, Engineering -- Periodicals'

  ENV['TIMDEX_URL']='https://timdex.mit.edu/graphql'
  ENV['SFX_HOST']='https://sfx.mit.edu/sfx_test'

  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
end

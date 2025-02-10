require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  ENV['GOOGLE_API_KEY'] = 'FAKE_GOOGLE_API_KEY'
  ENV['GOOGLE_CUSTOM_SEARCH_ID'] = 'FAKE_GOOGLE_CUSTOM_SEARCH_ID'
  ENV['MAX_AUTHORS'] = '3'
  ENV['PER_PAGE'] = '10'
  ENV['FLIPFLOP_KEY'] = 'yoyo'
  ENV['ALMA_OPENURL'] = 'https://na06.alma.exlibrisgroup.com/view/uresolver/01MIT_INST/openurl?'
  ENV['ALMA_SRU'] = 'https://mit.alma.exlibrisgroup.com/view/sru/01MIT_INST?version=1.2&operation=searchRetrieve&recordSchema=marcxml&query=alma.all_for_ui='
  ENV['ASPACE_SEARCH_URI'] = 'https://archivesspace.mit.edu/search?op[]=&field[]=creators_text&q[]='
  ENV['EXL_INST_ID'] = '01MIT_INST'
  ENV['PRIMO_SEARCH'] = 'true'
  ENV['PRIMO_API_URL'] = 'https://another_fake_server.example.com/v1'
  ENV['PRIMO_API_KEY'] = 'FAKE_PRIMO_API_KEY'
  ENV['PRIMO_VID'] = 'FAKE_PRIMO_VID'
  ENV['PRIMO_TAB'] = 'FAKE_PRIMO_TAB'
  ENV['PRIMO_BOOK_SCOPE'] = 'FAKE_PRIMO_BOOK_SCOPE'
  ENV['PRIMO_ARTICLE_SCOPE'] = 'FAKE_PRIMO_ARTICLE_SCOPE'
  ENV['PRIMO_MAIN_VIEW_TAB'] = 'all'
  ENV['PRIMO_SPLASH_PAGE'] = 'https://libraries.mit.edu/news/library-platform-before/32066/'
  ENV['MIT_PRIMO_URL'] = 'https://mit.primo.exlibrisgroup.com'
  ENV['SYNDETICS_PRIMO_URL'] = 'https://syndetics.com/index.php?client=primo'
  ENV['TIMDEX_URL'] = 'https://timdex.mit.edu/graphql'
  ENV['TACOS_URL'] = 'https://tacos.libraries.mit.edu/graphql/'
  ENV['ORIGINS'] = 'https://tacos.libraries.mit.edu'

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

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

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end

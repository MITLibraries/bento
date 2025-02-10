require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MitBento
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Compress text-like assets when serving them. This is mostly just needed
    # because we deploy to Heroku and not behind an app server where you'd
    # normally do this.
    config.middleware.use Rack::Deflater, include: Rack::Mime::MIME_TYPES
      .select { |_k, v| v =~ /text|json|javascript/ }.values.uniq

    # Allows for custom 404 page and other custom exception handling. Defaults
    # to regular handling if custom handling is not present.
    config.exceptions_app = self.routes

    config.action_dispatch.rescue_responses.merge!(
      'RecordController::NoSuchRecordError' => :not_found
    )
  end
end

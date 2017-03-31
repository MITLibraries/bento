require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MitBento
  class Application < Rails::Application
    # Replace with a lambda or method name defined in ApplicationController
    # to implement access control for the Flipflop dashboard.
    config.flipflop.dashboard_access_filter = :flipflop_access_control

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Compress text-like assets when serving them. This is mostly just needed
    # because we deploy to Heroku and not behind an app server where you'd
    # normally do this.
    config.middleware.use Rack::Deflater, include: Rack::Mime::MIME_TYPES
      .select { |_k, v| v =~ /text|json|javascript/ }.values.uniq
  end
end

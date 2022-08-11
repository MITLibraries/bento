Sentry.init do |config|
  return unless ENV.has_key?('SENTRY_DSN')
  config.dsn = ENV.fetch('SENTRY_DSN')
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.environment = ENV.fetch('SENTRY_ENV', 'unknown')
end

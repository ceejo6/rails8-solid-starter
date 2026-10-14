require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.secret_key_base = ENV["SECRET_KEY_BASE"]

  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :async
  config.action_cable.mount_path = nil

  config.active_support.report_deprecations = false
end

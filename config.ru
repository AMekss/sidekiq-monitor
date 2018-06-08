require 'puma'
require 'sidekiq'
require 'sidekiq/prometheus/exporter'
require './lib/health_check'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] }
end

use HealthCheck
run Sidekiq::Prometheus::Exporter.to_app

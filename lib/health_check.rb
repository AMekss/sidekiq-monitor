# frozen_string_literal: true
require "sidekiq"

# Rack middleware for service health checks
class HealthCheck
  HTTP_GET = 'GET'
  HTTP_OK = 200

  HEALTH_PATH = '/healthz'
  HEALTH_HEADERS = {
    'Content-Type' => 'text/plain; version=0.0.4',
    'Cache-Control' => 'no-cache'
  }.freeze

  PING_SUCCESS = 'PONG'
  STATE_GREEN = 'OK'
  STATE_RED = 'Oh crap!'

  def initialize(app)
    @app = app
  end

  def call(env)
    applicable?(env) ? health_response : @app.call(env)
  end

  private

  def health_response
    [HTTP_OK, HEALTH_HEADERS, [health_body]]
  end

  def health_body
    Sidekiq.redis(&:ping) == PING_SUCCESS ? STATE_GREEN : STATE_RED
  end

  def applicable?(env)
    env['REQUEST_PATH'] == HEALTH_PATH && env['REQUEST_METHOD'] == HTTP_GET
  end
end

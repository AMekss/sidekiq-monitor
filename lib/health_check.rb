# frozen_string_literal: true
require "sidekiq"
require "logger"

# Rack middleware for service health checks
class HealthCheck
  class UnsuccessfulRedisPing < StandardError; end

  HTTP_GET = 'GET'
  HTTP_OK = 200
  HTTP_ERROR = 500

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
    @logger = ::Logger.new(STDOUT)
  end

  def call(env)
    applicable?(env) ? health_response : @app.call(env)
  rescue => err
    @logger.error(err)
    [HTTP_ERROR, HEALTH_HEADERS, [STATE_RED]]
  end

  private

  def health_response
    check_redis!
    [HTTP_OK, HEALTH_HEADERS, [STATE_GREEN]]
  end

  def check_redis!
    result = Sidekiq.redis(&:ping)
    msg = "expect to have #{PING_SUCCESS}, but #{result} was received"
    raise UnsuccessfulRedisPing, msg if result != PING_SUCCESS
  end

  def applicable?(env)
    env['REQUEST_PATH'] == HEALTH_PATH && env['REQUEST_METHOD'] == HTTP_GET
  end
end

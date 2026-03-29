# frozen_string_literal: true

class Rack::Attack
  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  # Rails.cache ya está configurado

  # Rate limiting por IP - general
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets") || req.path.start_with?("/up")
  end

  # Rate limiting para login
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Rate limiting para creacion de reservas
  throttle("bookings/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.path.start_with?("/bookings") && req.post?
  end

  # Rate limiting para mensajes
  throttle("messages/ip", limit: 20, period: 5.minutes) do |req|
    req.ip if req.path.include?("messages") && req.post?
  end

  # Rate limiting para búsqueda
  throttle("search/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path == "/search" && req.get?
  end

  # Blocklist IPs (se puede poblar via Redis)
  # blocklist("block_trusted_proxies") do |req|
  #   Rack::Attack::Cache::REDIS_CLIENT.sismember("blocklist:ips", req.ip)
  # end

  # Allowlist para monitoreo
  safelist("allow from monitoring") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1" if req.path.start_with?("/up")
  end
end

# Log de Rack::Attack
ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
  Rails.logger.info("[Rack::Attack] #{name} #{payload[:request]}") if defined?(Rails.logger)
end

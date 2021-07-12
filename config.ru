# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

def master_process?
  Prometheus::PidProvider.worker_id == 'puma_master'
end

warmup do |app|
  client = Rack::MockRequest.new(app)
  client.get('/')
end

relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']
relative_url_root = nil if relative_url_root == ''

map relative_url_root || "/" do
  use Gitlab::Middleware::ReleaseEnv
  run Gitlab::Application
end

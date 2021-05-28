# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Redis::TraceChunks do
  let(:config_file_name) { "config/redis.trace_chunks.yml" }
  let(:environment_config_file_name) { "GITLAB_REDIS_TRACE_CHUNKS_CONFIG_FILE" }
  let(:config_old_format_socket) { "spec/fixtures/config/redis_trace_chunks_old_format_socket.yml" }
  let(:config_new_format_socket) { "spec/fixtures/config/redis_trace_chunks_new_format_socket.yml" }
  let(:old_socket_path) {"/path/to/old/redis.trace_chunks.sock" }
  let(:new_socket_path) {"/path/to/redis.trace_chunks.sock" }
  let(:config_old_format_host) { "spec/fixtures/config/redis_trace_chunks_old_format_host.yml" }
  let(:config_new_format_host) { "spec/fixtures/config/redis_trace_chunks_new_format_host.yml" }
  let(:redis_port) { 6383 }
  let(:redis_database) { 13 }
  let(:sentinel_port) { redis_port + 20000 }
  let(:config_with_environment_variable_inside) { "spec/fixtures/config/redis_trace_chunks_config_with_env.yml"}
  let(:config_env_variable_url) {"TEST_GITLAB_REDIS_TRACE_CHUNKS_URL"}
  let(:class_redis_url) { 'redis://localhost:6383' }

  include_examples "redis_shared_examples"
end

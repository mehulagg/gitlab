# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Redis::TraceChunks do
  let(:instance_specific_config_file) { "config/redis.trace_chunks.yml" }
  let(:environment_config_file_name) { "GITLAB_REDIS_TRACE_CHUNKS_CONFIG_FILE" }
  let(:class_redis_url) { 'redis://localhost:6383' }

  include_examples "redis_shared_examples"
end

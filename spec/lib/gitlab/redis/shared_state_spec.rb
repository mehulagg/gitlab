# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Redis::SharedState do
  let(:instance_specific_config_file) { "config/redis.shared_state.yml" }
  let(:environment_config_file_name) { "GITLAB_REDIS_SHARED_STATE_CONFIG_FILE" }
  let(:class_redis_url) { 'redis://localhost:6382' }

  include_examples "redis_shared_examples"
end

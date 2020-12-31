# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Samplers::SidekiqSampler do
  it_behaves_like 'metrics sampler', 'SIDEKIQ_SAMPLER'
end

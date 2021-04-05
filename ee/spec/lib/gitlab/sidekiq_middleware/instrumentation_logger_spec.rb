# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqMiddleware::InstrumentationLogger do
  describe '.keys' do
    it 'contains load balancer keys' do
      expected_keys = [
        :db_replica_count,
        :db_replica_cached_count,
        :db_primary_count,
        :db_primary_cached_count
      ]

      expect(described_class.keys).to include(*expected_keys)
    end
  end
end

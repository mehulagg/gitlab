# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Redis::HLL, :clean_gitlab_redis_shared_state do
  describe '.add' do
    it 'raise an error when using an invalid key format' do
      expect { described_class.add(key: 'test', value: 1, expiry: 1.day) }.to raise_error(Gitlab::Redis::KeyFormatError)
      expect { described_class.add(key: 'test-{metric', value: 1, expiry: 1.day) }.to raise_error(Gitlab::Redis::KeyFormatError)
    end

    it "doesn't raise error when having correct format" do
      expect { described_class.add(key: 'test-{metric}', value: 1, expiry: 1.day) }.not_to raise_error
      expect { described_class.add(key: 'test-{metric}-1', value: 1, expiry: 1.day) }.not_to raise_error
    end
  end
end

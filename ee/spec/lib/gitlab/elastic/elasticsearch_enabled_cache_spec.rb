# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Elastic::ElasticsearchEnabledCache, :clean_gitlab_redis_cache do
  describe '.fetch' do
    it 'remembers the result of the first invocation' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:project, 2) { false }).to eq(false)

      expect { |b| described_class.fetch(:project, 1, &b) }.not_to yield_control
      expect { |b| described_class.fetch(:project, 2, &b) }.not_to yield_control

      expect(described_class.fetch(:project, 1) { false }).to eq(true)
      expect(described_class.fetch(:project, 2) { true }).to eq(false)
    end

    it 'sets an expiry on the key the first time it creates the hash' do
      stub_const('::Gitlab::Elastic::ElasticsearchEnabledCache::EXPIRES_IN', 0)

      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:project, 2) { false }).to eq(false)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
      expect(described_class.fetch(:project, 2) { true }).to eq(true)
    end

    it 'does not set an expiry on the key after the hash is already created' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)

      stub_const('::Gitlab::Elastic::ElasticsearchEnabledCache::EXPIRES_IN', 0)

      expect(described_class.fetch(:project, 2) { false }).to eq(false)

      expect(described_class.fetch(:project, 1) { false }).to eq(true)
      expect(described_class.fetch(:project, 2) { true }).to eq(false)
    end
  end

  describe '.delete' do
    it 'clears the cached value' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:project, 2) { false }).to eq(false)

      described_class.delete(:project)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
      expect(described_class.fetch(:project, 2) { true }).to eq(true)
    end

    it 'does not clear the cache for another type' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:namespace, 1) { false }).to eq(false)

      described_class.delete(:project)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
      expect(described_class.fetch(:namespace, 1) { true }).to eq(false)
    end
  end

  describe '.delete_record' do
    it 'clears the cached value' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)

      described_class.delete_record(:project, 1)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
    end

    it 'does not clear the cache for another record of the same type' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:project, 2) { false }).to eq(false)

      described_class.delete_record(:project, 1)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
      expect(described_class.fetch(:project, 2) { true }).to eq(false)
    end

    it 'does not clear the cache for another record of a different type' do
      expect(described_class.fetch(:project, 1) { true }).to eq(true)
      expect(described_class.fetch(:namespace, 1) { false }).to eq(false)

      described_class.delete_record(:project, 1)

      expect(described_class.fetch(:project, 1) { false }).to eq(false)
      expect(described_class.fetch(:namespace, 1) { true }).to eq(false)
    end
  end
end

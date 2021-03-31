# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataQueries do
  before do
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  describe '.count' do
    it 'returns the raw SQL' do
      expect(described_class.count(User)).to start_with('SELECT COUNT("users"."id") FROM "users"')
    end

    it 'does not mix a nil column with keyword arguments' do
      expect(described_class).to receive(:raw_sql).with(User, nil)

      described_class.count(User, start: 1, finish: 2)
    end
  end

  describe '.distinct_count' do
    it 'returns the raw SQL' do
      expect(described_class.distinct_count(Issue, :author_id)).to eq('SELECT COUNT(DISTINCT "issues"."author_id") FROM "issues"')
    end

    it 'does not mix a nil column with keyword arguments' do
      expect(described_class).to receive(:raw_sql).with(Issue, nil, :distinct)

      described_class.distinct_count(Issue, nil, start: 1, finish: 2)
    end
  end

  describe '.redis_usage_data' do
    subject(:redis_usage_data) { described_class.redis_usage_data { 42 } }

    it 'returns a class for redis_usage_data with a counter call' do
      expect(described_class.redis_usage_data(Gitlab::UsageDataCounters::WikiPageCounter))
        .to eq(redis_usage_data_counter: Gitlab::UsageDataCounters::WikiPageCounter)
    end

    it 'returns a stringified block for redis_usage_data with a block' do
      is_expected.to include(:redis_usage_data_block)
      expect(redis_usage_data[:redis_usage_data_block]).to start_with('#<Proc:')
    end
  end

  describe '.sum' do
    it 'returns the raw SQL' do
      expect(described_class.sum(Issue, :weight)).to eq('SELECT SUM("issues"."weight") FROM "issues"')
    end
  end

  describe '.add' do
    it 'returns the combined raw SQL with an inner query' do
      expect(described_class.add('SELECT COUNT("users"."id") FROM "users"',
                                 'SELECT COUNT("issues"."id") FROM "issues"'))
        .to eq('SELECT (SELECT COUNT("users"."id") FROM "users") + (SELECT COUNT("issues"."id") FROM "issues")')
    end
  end

  describe 'min/max methods' do
    it 'returns nil' do
      # user min/max
      expect(described_class.user_minimum_id).to eq(nil)
      expect(described_class.user_maximum_id).to eq(nil)

      # issue min/max
      expect(described_class.issue_minimum_id).to eq(nil)
      expect(described_class.issue_maximum_id).to eq(nil)

      # deployment min/max
      expect(described_class.deployment_minimum_id).to eq(nil)
      expect(described_class.deployment_maximum_id).to eq(nil)

      # project min/max
      expect(described_class.project_minimum_id).to eq(nil)
      expect(described_class.project_maximum_id).to eq(nil)
    end
  end
end

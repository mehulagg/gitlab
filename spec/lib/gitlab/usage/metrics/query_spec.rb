# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Query do
  before do
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  describe '.count' do
    it 'returns the raw SQL' do
      expect(described_class.for(:count, User)).to start_with('SELECT COUNT("users"."id") FROM "users"')
    end

    it 'does not mix a nil column with keyword arguments' do
      expect(described_class.for(:count, User, nil)).to eq('SELECT COUNT("users"."id") FROM "users"')
    end
  end

  describe '.distinct_count' do
    it 'returns the raw SQL' do
      expect(described_class.for(:distinct_count, Issue, :author_id)).to eq('SELECT COUNT(DISTINCT "issues"."author_id") FROM "issues"')
    end

    it 'does not mix a nil column with keyword arguments' do
      expect(described_class.for(:distinct_count, Issue, nil)).to eq('SELECT COUNT(DISTINCT "issues"."id") FROM "issues"')
    end
  end

  describe '.sum' do
    it 'returns the raw SQL' do
      expect(described_class.for(:sum, Issue, :weight)).to eq('SELECT SUM("issues"."weight") FROM "issues"')
    end
  end

  describe '.add' do
    it 'returns the combined raw SQL with an inner query' do
      expect(described_class.for(:add, ['SELECT COUNT("users"."id") FROM "users"',
                                        'SELECT COUNT("issues"."id") FROM "issues"']))
        .to eq('SELECT (SELECT COUNT("users"."id") FROM "users") + (SELECT COUNT("issues"."id") FROM "issues")')
    end
  end

  describe '.histogram' do
    it 'returns the histogram sql' do
      expect(described_class.for(:histogram, AlertManagement::HttpIntegration.active,
            :project_id, buckets: 1..2, bucket_size: 101))
        .to match(/^WITH "count_cte" AS #{Gitlab::Database::AsWithMaterialized.materialized_if_supported}/)
    end
  end
end

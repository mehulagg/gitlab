# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataNonSqlMetrics do
  let(:default_count) { Gitlab::UsageDataNonSqlMetrics::SQL_METRIC_DEFAULT }

  describe '.count' do
    it 'returns default value for count' do
      expect(described_class.count(User)).to eq(default_count)
    end
  end

  describe '.distinct_count' do
    it 'returns default value for distinct count' do
      expect(described_class.distinct_count(User)).to eq(default_count)
    end
  end

  describe '.estimate_batch_distinct_count' do
    it 'returns default value for estimate_batch_distinct_count' do
      expect(described_class.estimate_batch_distinct_count(User)).to eq(default_count)
    end
  end

  describe '.sum' do
    it 'returns default value for sum' do
      expect(described_class.sum(JiraImportState.finished, :imported_issues_count)).to eq(default_count)
    end
  end

  describe '.histogram' do
    it 'returns default value for histogram' do
      expect(described_class.histogram(JiraImportState.finished, :imported_issues_count, buckets: [], bucket_size: 0)).to eq(default_count)
    end
  end

  describe 'min/max methods' do
    it 'returns nil' do
      # user min/max
      expect(described_class.minimum_id(User)).to eq(nil)
      expect(described_class.maximum_id(User)).to eq(nil)

      # issue min/max
      expect(described_class.minimum_id(Issue)).to eq(nil)
      expect(described_class.maximum_id(Issue)).to eq(nil)

      # deployment min/max
      expect(described_class.minimum_id(Deployment)).to eq(nil)
      expect(described_class.maximum_id(Deployment)).to eq(nil)

      # project min/max
      expect(described_class.minimum_id(Project)).to eq(nil)
      expect(described_class.maximum_id(Project)).to eq(nil)
    end
  end
end

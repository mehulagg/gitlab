# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::TimeConstraint do
  describe ".build" do
    around do |example|
      freeze_time do
        example.run
      end
    end

    it 'has empty hash for unknown data source' do
      expect { described_class.new('28d', 'unknown').build }.to raise_error('Unknown data source: unknown for TimeConstraint')
    end

    context 'for database' do
      it 'has the correct 28 days time frame' do
        expect(described_class.new('28d', 'database').build).to eq({ created_at: 30.days.ago..2.days.ago })
      end

      it 'has empty hash for all tim frame' do
        expect(described_class.new('all', 'database').build).to eq({})
      end

      it 'returns nil for none time frame' do
        expect(described_class.new('none', 'database').build).to eq(nil)
      end

      it 'raise error for invalid time frame' do
        expect { described_class.new('27d', 'database').build }.to raise_error('Unknown time frame: 27d for TimeConstraint')
      end
    end

    context 'for redis_hll' do
      it 'has the correct 28 days time frame' do
        expect(described_class.new('28d', 'redis_hll').build).to eq({ start_date: 4.weeks.ago.to_date, end_date: Date.current })
      end

      it 'has the correct 7 days time frame' do
        expect(described_class.new('7d', 'redis_hll').build).to eq({ start_date: 7.days.ago.to_date, end_date: Date.current })
      end

      it 'has empty hash' do
        expect { described_class.new('29d', 'redis_hll').build }.to raise_error('Unknown time frame: 29d for TimeConstraint')
      end
    end
  end
end

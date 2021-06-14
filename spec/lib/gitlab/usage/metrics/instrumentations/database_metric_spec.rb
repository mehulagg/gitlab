# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::DatabaseMetric do
  subject do
    described_class.tap do |m|
      m.relation { Issue }
      m.operation :count
      m.start { m.relation.minimum(:id) }
      m.finish { m.relation.maximum(:id) }
    end.new(time_frame: 'all')
  end

  describe '#value' do
    let_it_be(:issue_1) { create(:issue, id: 314) }
    let_it_be(:issue_2) { create(:issue, id: 451) }
    let_it_be(:issue_3) { create(:issue, id: 949) }

    before do
      allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
    end

    it 'calculates a correct result' do
      expect(subject.value).to eq(3)
    end

    it 'caches the result of start and finish', :use_clean_rails_redis_caching do
      subject.value

      expect(Rails.cache.read('metric_instrumentation/issues_minimum_id')).to eq(314)
      expect(Rails.cache.read('metric_instrumentation/issues_maximum_id')).to eq(949)
    end

    context 'with start and finish not called' do
      let_it_be(:issue_4) { create(:issue, id: 212) }

      subject do
        described_class.tap do |m|
          m.relation { Issue }
          m.operation :count
        end.new(time_frame: 'all')
      end

      it 'calculates a correct result' do
        expect(subject.value).to eq(4)
      end
    end

    context 'with cache_start_and_finish_as called' do
      subject do
        described_class.tap do |m|
          m.relation { Issue }
          m.operation :count
          m.start { m.relation.minimum(:id) }
          m.finish { m.relation.maximum(:id) }
          m.cache_start_and_finish_as :special_issue_count
        end.new(time_frame: 'all')
      end

      it 'caches using the key name passed', :use_clean_rails_redis_caching do
        subject.value

        expect(Rails.cache.read('metric_instrumentation/special_issue_count_minimum_id')).to eq(314)
        expect(Rails.cache.read('metric_instrumentation/special_issue_count_maximum_id')).to eq(949)
      end
    end
  end
end

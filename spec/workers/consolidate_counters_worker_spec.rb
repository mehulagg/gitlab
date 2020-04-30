# frozen_string_literal: true

require 'spec_helper'

describe ConsolidateCountersWorker do
  class StubProjectStatisticsEvent < ApplicationRecord
    self.table_name = 'project_statistics_events'

    belongs_to :stub_project_statistics, foreign_key: :project_statistics_id
  end

  class StubProjectStatistics < ApplicationRecord
    self.table_name = 'project_statistics'

    belongs_to :project

    include CounterAttribute

    counter_attribute :build_artifacts_size
  end

  let(:model) { StubProjectStatistics }
  let(:scheduling_lock_key) { "consolidate-counters:scheduling:#{model}" }

  describe '.exclusively_perform_async' do
    subject { described_class.exclusively_perform_async(model) }

    before do
      Gitlab::Redis::SharedState.with do |redis|
        redis.del(scheduling_lock_key)
      end
    end

    context 'when no workers are scheduled' do
      it 'takes exclusive lease of the schedule' do
        subject

        expect(described_class.worker_scheduled?(model))
          .to be_truthy
      end

      it 'schedules the worker some time in the future' do
        subject

        job = described_class.jobs.last
        job_delay = job.fetch('at') - job.fetch('created_at')

        expect(job_delay).to be_within(5).of(described_class::DELAY)
      end
    end

    context 'when a worker is already scheduled' do
      before do
        described_class.exclusively_perform_async(model)
      end

      it 'exits immediately' do
        expect(described_class.worker_scheduled?(model))
          .to be_truthy

        expect { described_class.exclusively_perform_async(model) }
          .not_to change { described_class.jobs.size }
      end
    end
  end

  describe '#perform' do
    let(:processing_lock_key) { "consolidate-counters:processing:#{model}" }
    let(:worker) { described_class.new }

    after do
      Gitlab::Redis::SharedState.with do |redis|
        redis.del(processing_lock_key)
      end
    end

    subject { worker.perform(model.name) }

    it 'obtains an exclusive lease during processing' do
      expect(worker)
        .to receive(:in_lock)
        .with("consolidate-counters:processing:#{model}", ttl: described_class::LOCK_TTL)
        .and_call_original

      subject
    end

    it 'consolidates counter attributes' do
      expect(model)
        .to receive(:slow_consolidate_counter_attributes!)
        .and_call_original

      subject
    end
  end
end

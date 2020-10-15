# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::AdvanceStageWorker, :clean_gitlab_redis_shared_state do
  let(:project) { create(:project) }
  let(:bulk_import) { create(:bulk_import) }

  subject { described_class.new }

  describe '#perform' do
    context 'when there are remaining jobs' do
      it 'reschedules itself' do
        expect(subject)
          .to receive(:wait_for_jobs)
          .with({ '123' => 2 })
          .and_return({ '123' => 1 })

        expect(described_class)
          .to receive(:perform_in)
          .with(described_class::INTERVAL, bulk_import.id, { '123' => 1 }, :finish)

        subject.perform(bulk_import.id, { '123' => 2 }, :finish)
      end
    end

    context 'when there are no remaining jobs' do
      before do
        allow(subject)
          .to receive(:wait_for_jobs)
          .with({ '123' => 2 })
          .and_return({})
      end

      it 'schedules the next stage' do
        expect(BulkImports::Stage::FinishImportWorker)
          .to receive(:perform_async)
          .with(bulk_import.id)

        subject.perform(bulk_import.id, { '123' => 2 }, :finish)
      end

      it 'raises KeyError when the stage name is invalid' do
        expect { subject.perform(project.id, { '123' => 2 }, :test) }
          .to raise_error(KeyError)
      end
    end
  end

  describe '#wait_for_jobs' do
    it 'waits for jobs to complete and returns a new pair of keys to wait for' do
      waiter1 = double(:waiter1, jobs_remaining: 1, key: '123')
      waiter2 = double(:waiter2, jobs_remaining: 0, key: '456')

      expect(Gitlab::JobWaiter)
        .to receive(:new)
        .ordered
        .with(2, '123')
        .and_return(waiter1)

      expect(Gitlab::JobWaiter)
        .to receive(:new)
        .ordered
        .with(1, '456')
        .and_return(waiter2)

      expect(waiter1)
        .to receive(:wait)
        .with(described_class::BLOCKING_WAIT_TIME)

      expect(waiter2)
        .to receive(:wait)
        .with(described_class::BLOCKING_WAIT_TIME)

      new_waiters = subject.wait_for_jobs({ '123' => 2, '456' => 1 })

      expect(new_waiters).to eq({ '123' => 1 })
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScheduleMergeRequestCleanupRefsWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    before do
      allow(MergeRequest::CleanupSchedule)
        .to receive(:scheduled)
        .with(described_class::LIMIT)
        .and_return([
          double(merge_request_id: 1),
          double(merge_request_id: 2),
          double(merge_request_id: 3),
          double(merge_request_id: 4)
        ])
    end

    it 'does nothing if the database is read-only' do
      allow(Gitlab::Database).to receive(:read_only?).and_return(true)
      expect(MergeRequestCleanupRefsWorker).not_to receive(:bulk_perform_in)

      worker.perform
    end

    it 'schedules MergeRequestCleanupRefsWorker to be performed by batch' do
      expect(MergeRequestCleanupRefsWorker)
        .to receive(:bulk_perform_in)
        .with(
          described_class::DELAY,
          [[1], [2], [3], [4]],
          batch_size: described_class::BATCH_SIZE
        )

      worker.perform
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::SyncMergeRequestWorker do
  describe '#perform' do
    let(:merge_request) { create(:merge_request) }
    let(:merge_request_id) { merge_request.id }

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [merge_request_id] }

      before do
        stub_request(:post, 'https://sample.atlassian.net/rest/devinfo/0.10/bulk').to_return(status: 200, body: '', headers: {})
      end

      it 'calls JiraConnect::SyncService#execute' do
        sync_service = JiraConnect::SyncService.new(merge_request.project)
        allow(JiraConnect::SyncService).to receive(:new) { sync_service }

        expect(sync_service).to receive(:execute)
          .exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times
          .with(merge_requests: [merge_request])

        subject
      end

      context 'when MR no longer exists' do
        let(:merge_request_id) { non_existing_record_id }

        it 'does not call JiraConnect::SyncService' do
          expect(JiraConnect::SyncService).not_to receive(:new)

          subject
        end
      end
    end
  end
end

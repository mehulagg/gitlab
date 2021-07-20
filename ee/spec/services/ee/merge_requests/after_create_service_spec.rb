# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::AfterCreateService do
  let_it_be(:merge_request) { create(:merge_request) }

  let(:service_object) { described_class.new(project: merge_request.target_project, current_user: merge_request.author) }

  describe '#execute' do
    subject(:execute) { service_object.execute(merge_request) }

    before do
      allow(Ci::SyncReportsToReportApprovalRulesWorker).to receive(:perform_async)
    end

    context 'when the merge request has actual_head_pipeline' do
      let(:pipeline_id) { 1881 }

      before do
        allow(merge_request).to receive(:head_pipeline_id).and_return(pipeline_id)
        allow(merge_request).to receive(:update_head_pipeline).and_return(true)
      end

      it 'schedules a background job to sync security reports to approval rules' do
        execute

        expect(merge_request).to have_received(:update_head_pipeline).ordered
        expect(Ci::SyncReportsToReportApprovalRulesWorker).to have_received(:perform_async).ordered.with(pipeline_id)
      end
    end

    context 'when the merge request does not have actual_head_pipeline' do
      it 'does not schedule a background job to sync security reports to approval rules' do
        execute

        expect(Ci::SyncReportsToReportApprovalRulesWorker).not_to have_received(:perform_async)
      end
    end
  end
end

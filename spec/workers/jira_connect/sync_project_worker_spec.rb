# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::SyncProjectWorker, factory_default: :keep do
  describe '#perform' do
    let_it_be(:project) { create_default(:project) }
    let!(:mr_with_jira_title) { create(:merge_request, :unique_branches, title: 'TEST-123') }
    let!(:mr_with_jira_description) { create(:merge_request, :unique_branches, description: 'TEST-323') }
    let!(:closed_mr_with_jira_reference) { create(:closed_merge_request, :unique_branches, description: 'TEST-323', title: 'TEST-123') }
    let!(:merged_mr_with_jira_reference) { create(:merged_merge_request, :unique_branches, description: 'TEST-323', title: 'TEST-123') }
    let!(:mr_with_other_title) { create(:merge_request, :unique_branches) }
    let!(:jira_connect_sync_service) { JiraConnect::SyncService.new(project) }
    let(:job_args) { [project.id] }

    before do
      allow(JiraConnect::SyncService).to receive(:new) { jira_connect_sync_service }
    end

    context 'when the project is not found' do
      it 'does not raise an error' do
        expect { described_class.new.perform('non_existing_record_id') }.not_to raise_error
      end
    end

    it_behaves_like 'an idempotent worker' do
      it 'syncs open merge requests with Jira references in title or description' do
        expect(jira_connect_sync_service).to receive(:execute).twice
          .with(merge_requests: [mr_with_jira_description, mr_with_jira_title])

        subject
      end

      context 'when the number of merge requests to sync is higher than the limit' do
        before do
          stub_const("#{described_class}::MERGE_REQUEST_LIMIT", 1)
        end

        it 'syncs only the most recent merge requests within the limit' do
          expect(jira_connect_sync_service).to receive(:execute).twice
            .with(merge_requests: [mr_with_jira_description])

          subject
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::SyncProjectWorker do
  describe '#perform' do
    let_it_be(:project) { create_default(:project) }
    let!(:mr_with_jira_title) { create(:merge_request, :unique_branches, title: 'TEST-123') }
    let!(:mr_with_jira_description) { create(:merge_request, :unique_branches, description: 'TEST-323') }
    let!(:closed_mr_with_jira_reference) { create(:closed_merge_request, :unique_branches, description: 'TEST-323', title: 'TEST-123') }
    let!(:merged_mr_with_jira_reference) { create(:merged_merge_request, :unique_branches, description: 'TEST-323', title: 'TEST-123') }
    let!(:mr_with_other_title) { create(:merge_request, :unique_branches) }

    it 'syncs open merge requests with Jira references in title or description' do
      expect_next_instance_of(JiraConnect::SyncService) do |sync_service|
        expect(sync_service).to receive(:execute).with(merge_requests: [mr_with_jira_title, mr_with_jira_description])
      end
      described_class.new.perform(project.id)
    end

    context 'when the project is not found' do
      it 'does not raise an error' do
        expect { described_class.new.perform('non_existing_record_id') }.not_to raise_error
      end
    end

    context 'when project has more than 50 MRs to sync' do
      let!(:merge_requests) { create_list(:merge_request, 2, :unique_branches, description: 'TEST-323', title: 'TEST-123', source_project: project) }

      before do
        stub_const("#{described_class}::MERGE_REQUEST_LIMIT", 1)
      end

      specify do
        expect(JiraConnect::SyncService).not_to receive(:new)
        described_class.new.perform(project.id)
      end
    end
  end
end

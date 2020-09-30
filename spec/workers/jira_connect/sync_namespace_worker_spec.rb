# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::SyncNamespaceWorker do
  describe '#perform' do
    let_it_be(:namespace) { create_default(:namespace) }
    let_it_be(:project) { create_default(:project) }
    let!(:merge_request_with_jira_title) { create(:merge_request, :unique_branches, title: 'TEST-123') }
    let!(:merge_request_with_jira_description) { create(:merge_request, :unique_branches, description: 'TEST-323') }
    let!(:merge_request_in_namespace) { create(:merge_request, :unique_branches) }
    let(:other_namespace) { create(:namespace) }
    let(:other_project) { create(:project, namespace: other_namespace) }
    let!(:other_merge_request) { create(:merge_request, target_project: other_project, source_project: other_project) }

    it 'starts jobs to sync MRs', :aggregate_failures do
      expect(JiraConnect::SyncMergeRequestWorker).to receive(:perform_async).with(merge_request_with_jira_title.id)
      expect(JiraConnect::SyncMergeRequestWorker).to receive(:perform_async).with(merge_request_with_jira_description.id)
      expect(JiraConnect::SyncMergeRequestWorker).not_to receive(:perform_async).with(other_merge_request.id)

      described_class.new.perform(namespace)
    end

    context 'when namespace has more than 30 MRs' do
      let!(:merge_requests) { create_list(:merge_request, 31, :unique_branches, description: 'TEST-323')}

      specify do
        expect(JiraConnect::SyncMergeRequestWorker).not_to receive(:perform_async)
        described_class.new.perform(namespace)
      end
    end
  end
end

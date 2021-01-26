# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Integrations::Jira::ByIdsFinder do
  include ReactiveCachingHelpers

  let_it_be(:project) { create(:project) }

  let(:jira_issue_ids) { %w[10000 10001] }
  let(:finder_params) { [project, issue_ids: jira_issue_ids] }

  let(:by_ids_finder) { described_class.new(project, jira_issue_ids) }

  describe '#execute' do
    context 'when reactive_caching is still fetching data' do
      it 'returns nil' do
        expect(by_ids_finder.execute).to be_nil
      end
    end

    context 'when reactive_caching has finished' do
      before do
        allow_next_instance_of(::Projects::Integrations::Jira::IssuesFinder, *finder_params) do |issues_finder|
          allow(issues_finder).to receive(:execute).and_return([{ jira_issue: 1 }, { jira_issue: 2 }])
        end

        synchronous_reactive_cache(by_ids_finder)
      end

      it 'returns issues encapsulated in hash' do
        expect(by_ids_finder.execute).to eq(issues: [{ jira_issue: 1 }, { jira_issue: 2 }], error: nil)
      end
    end

    context 'when reactive_caching failed with ::Projects::Integrations::Jira::IssuesFinder::IntegrationError' do
      before do
        allow_next_instance_of(::Projects::Integrations::Jira::IssuesFinder, *finder_params) do |issues_finder|
          allow(issues_finder).to receive(:execute).and_raise(::Projects::Integrations::Jira::IssuesFinder::IntegrationError, 'project key not set')
        end

        synchronous_reactive_cache(by_ids_finder)
      end

      it 'returns empty issues list with error message' do
        expect(by_ids_finder.execute).to eq(issues: [], error: 'project key not set')
      end
    end

    context 'when reactive_caching failed with ::Projects::Integrations::Jira::IssuesFinder::RequestError' do
      before do
        allow_next_instance_of(::Projects::Integrations::Jira::IssuesFinder, *finder_params) do |issues_finder|
          allow(issues_finder).to receive(:execute).and_raise(::Projects::Integrations::Jira::IssuesFinder::RequestError, 'jira instance not found')
        end

        synchronous_reactive_cache(by_ids_finder)
      end

      it 'returns empty issues list with error message' do
        expect(by_ids_finder.execute).to eq(issues: [], error: 'jira instance not found')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::MergeService do
  let(:user) { create(:user) }
  let(:merge_request) { create(:merge_request, :simple) }
  let(:project) { merge_request.project }
  let(:service) { described_class.new(project: project, current_user: user, params: { sha: merge_request.diff_head_sha, commit_message: 'Awesome message' }) }

  before do
    project.add_maintainer(user)
  end

  describe '#execute' do
    context 'project has exceeded size limit' do
      before do
        allow(project.repository_size_checker).to receive(:above_size_limit?).and_return(true)
      end

      it 'persists the correct error message' do
        service.execute(merge_request)

        expect(merge_request.merge_error).to include('This merge request cannot be merged')
      end
    end

    context 'when merge request rule exists' do
      let(:approver) { create(:user) }
      let!(:approval_rule) { create :approval_merge_request_rule, merge_request: merge_request, users: [approver] }
      let!(:approval) { create :approval, merge_request: merge_request, user: approver }

      it 'creates approved_approvers' do
        allow(service).to receive(:execute_hooks)

        perform_enqueued_jobs do
          service.execute(merge_request)
        end
        merge_request.reload
        rule = merge_request.approval_rules.first

        expect(merge_request.merged?).to eq(true)
        expect(rule.approved_approvers).to contain_exactly(approver)
      end
    end

    context 'with jira issue enforcement' do
      using RSpec::Parameterized::TableSyntax

      subject do
        perform_enqueued_jobs do
          service.execute(merge_request)
        end
      end

      where(:prevent_merge, :issue_specified, :merged) do
        true  | true  | true
        true  | false | false
        false | true  | true
        false | false | true
      end

      with_them do
        before do
          allow(project).to receive(:prevent_merge_without_jira_issue?).and_return(prevent_merge)
          allow(Atlassian::JiraIssueKeyExtractor).to receive(:has_keys?)
                                                       .with(merge_request.title, merge_request.description)
                                                       .and_return(issue_specified)
        end

        it 'sets the correct merged state and raises an error when applicable', :aggregate_failures do
          subject

          expect(merge_request.reload.merged?).to eq(merged)
          expect(merge_request.merge_error).to include('Before this can be merged, a Jira issue must be linked in the title or description') unless merged
        end
      end
    end
  end

  it_behaves_like 'merge validation hooks', persisted: true
end

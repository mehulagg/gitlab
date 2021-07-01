# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::ResetApprovalsService do
  let(:service) { described_class.new(project: project, current_user: current_user) }
  let(:current_user) { merge_request.author }
  let(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, namespace: group, approvals_before_merge: 1, reset_approvals_on_push: true) }

  let(:merge_request) do
    create(:merge_request,
      source_project: project,
      source_branch: project.default_branch,
      target_branch: 'feature',
      target_project: project,
      merge_when_pipeline_succeeds: true,
      merge_user: user)
  end

  let(:commits) { merge_request.commits }
  let(:oldrev) { commits.last.id }
  let(:newrev) { commits.first.id }
  let(:approver) { create(:user) }
  let(:notification_service) { spy('notification_service') }

  def approval_todos(merge_request)
    Todo.where(action: Todo::APPROVAL_REQUIRED, target: merge_request)
  end

  describe "#execute" do
    before do
      allow(service).to receive(:execute_hooks)
      allow(NotificationService).to receive(:new) { notification_service }
      project.add_developer(approver)

      perform_enqueued_jobs do
        merge_request.update!(approver_ids: [approver].map(&:id).join(','))
      end

      merge_request.approvals.create!(user_id: approver.id)
    end

    it 'resets approvals' do
      service.execute("refs/heads/master", newrev)
      merge_request.reload

      expect(merge_request.approvals).to be_empty
      expect(approval_todos(merge_request).map(&:user)).to contain_exactly(approver)
    end
  end
end

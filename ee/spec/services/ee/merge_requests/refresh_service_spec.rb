# frozen_string_literal: true

require 'spec_helper'

describe MergeRequests::RefreshService do
  include ProjectForksHelper

  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group, approvals_before_merge: 1, reset_approvals_on_push: true) }
  let(:forked_project) { fork_project(project, fork_user, repository: true) }

  let(:fork_user) { create(:user) }

  let(:source_branch) { 'between-create-delete-modify-move' }
  let(:merge_request) do
    create(:merge_request,
      source_project: project,
      source_branch: source_branch,
      target_branch: 'master',
      target_project: project)
  end
  let(:another_merge_request) do
    create(:merge_request,
      source_project: project,
      source_branch: source_branch,
      target_branch: 'test',
      target_project: project)
  end
  let(:forked_merge_request) do
    create(:merge_request,
      source_project: forked_project,
      source_branch: source_branch,
      target_branch: 'master',
      target_project: project)
  end
  let(:oldrev) { TestEnv::BRANCH_SHA[source_branch] }
  let(:newrev) { TestEnv::BRANCH_SHA['after-create-delete-modify-move'] } # Pretend source_branch is now updated

  subject { service.execute(oldrev, newrev, "refs/heads/#{source_branch}") }

  describe '#execute' do
    context '#update_approvers' do
      let(:owner) { create(:user) }
      let(:current_user) { merge_request.author }
      let(:service) { described_class.new(project, current_user) }
      let(:enable_code_owner) { true }
      let(:todo_service) { double(:todo_service) }
      let(:notification_service) { double(:notification_service) }

      before do
        stub_licensed_features(code_owners: enable_code_owner)

        allow(service).to receive(:mark_pending_todos_done)
        allow(service).to receive(:notify_about_push)
        allow(service).to receive(:execute_hooks)
        allow(service).to receive(:todo_service).and_return(todo_service)
        allow(service).to receive(:notification_service).and_return(notification_service)

        group.add_master(fork_user)

        merge_request
        another_merge_request
        forked_merge_request
      end

      context 'when code owners disabled' do
        let(:enable_code_owner) { false }

        it 'does nothing' do
          expect(::Gitlab::CodeOwners).not_to receive(:for_merge_request)

          subject
        end
      end

      context 'when code owners enabled' do
        let(:old_owners) { [] }
        let(:new_owners) { [] }
        let(:relevant_merge_requests) { [merge_request, another_merge_request] }

        before do
          relevant_merge_requests.each do |merge_request|
            expect(::Gitlab::CodeOwners).to receive(:for_merge_request).with(merge_request).and_return(new_owners)
            expect(::Gitlab::CodeOwners).to receive(:for_merge_request).with(merge_request, merge_request_diff: anything).and_wrap_original do |m, *args|
              expect(args.last[:merge_request_diff]).to eq(merge_request.merge_request_diffs.order(id: :desc).offset(1).first)

              old_owners
            end
          end

          [forked_merge_request].each do |merge_request|
            expect(::Gitlab::CodeOwners).not_to receive(:for_merge_request).with(merge_request, anything)
          end
        end

        shared_examples 'notification and todo' do
          it 'does nothing if owners do not change' do
            expect(service.todo_service).not_to receive(:add_merge_request_approvers)
            expect(service.notification_service).not_to receive(:add_merge_request_approvers)

            subject
          end

          context 'when new owners are being added' do
            let(:new_owners) { [owner] }

            it 'notifies new owner' do
              relevant_merge_requests.each do |merge_request|
                expect(todo_service).to receive(:add_merge_request_approvers).with(merge_request, [owner])
                expect(notification_service).to receive(:add_merge_request_approvers).with(merge_request, [owner], current_user)
              end

              subject
            end
          end

          context 'when old owners are being removed' do
            let(:old_owners) { [owner] }

            it 'does nothing' do
              expect(service.todo_service).not_to receive(:add_merge_request_approvers)
              expect(service.notification_service).not_to receive(:add_merge_request_approvers)

              subject
            end
          end
        end

        context 'merge request has overwritten approvers' do
          include_examples 'notification and todo'
        end

        context 'merge request has default approvers' do
          let(:existing_approver) { create(:user) }

          before do
            create(:approver, target: merge_request, user: existing_approver)
          end

          include_examples 'notification and todo'

          context 'when new owners are being added' do
            let(:new_owners) { [owner] }

            it 'creates Approver' do
              allow(service.todo_service).to receive(:add_merge_request_approvers)
              allow(service.notification_service).to receive(:add_merge_request_approvers)

              subject

              expect(merge_request.approvers.first.user).to eq(existing_approver)
              expect(merge_request.approvers.last.user).to eq(owner)
            end
          end
        end
      end
    end
  end
end

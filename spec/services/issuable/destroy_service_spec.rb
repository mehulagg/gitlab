# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issuable::DestroyService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public) }

  subject(:service) { described_class.new(project, user) }

  describe '#execute' do
    shared_examples_for 'service deleting todos' do
      it 'destroys associated todos' do
        create(:todo, target: issuable, user: user, author: user, project: project)

        control_count = ActiveRecord::QueryRecorder.new { service.execute(issuable) }.count

        create(:todo, target: other_issuable, user: user, author: user, project: project)
        create(:todo, target: other_issuable, user: user, author: user, project: project)

        expect { service.execute(other_issuable) }.not_to exceed_query_limit(control_count)
        expect(other_issuable.todos.count).to eq(0)
      end
    end

    context 'when issuable is an issue' do
      let!(:issue) { create(:issue, project: project, author: user, assignees: [user]) }

      it 'destroys the issue' do
        expect { service.execute(issue) }.to change { project.issues.count }.by(-1)
      end

      it 'updates open issues count cache' do
        expect_any_instance_of(Projects::OpenIssuesCountService).to receive(:refresh_cache)

        service.execute(issue)
      end

      it 'updates the todo caches for users with todos on the issue' do
        create(:todo, target: issue, user: user, author: user, project: project)

        expect { service.execute(issue) }
          .to change { user.todos_pending_count }.from(1).to(0)
      end

      it 'invalidates the issues count cache for the assignees' do
        expect_any_instance_of(User).to receive(:invalidate_cache_counts).once
        service.execute(issue)
      end

      it_behaves_like 'service deleting todos' do
        let(:issuable) { issue }
        let(:other_issuable) { create(:issue, project: project, author: user, assignees: [user]) }
      end
    end

    context 'when issuable is a merge request' do
      let!(:merge_request) { create(:merge_request, target_project: project, source_project: project, author: user, assignees: [user]) }

      it 'destroys the merge request' do
        expect { service.execute(merge_request) }.to change { project.merge_requests.count }.by(-1)
      end

      it 'updates open merge requests count cache' do
        expect_any_instance_of(Projects::OpenMergeRequestsCountService).to receive(:refresh_cache)

        service.execute(merge_request)
      end

      it 'invalidates the merge request caches for the MR assignee' do
        expect_any_instance_of(User).to receive(:invalidate_cache_counts).once
        service.execute(merge_request)
      end

      it 'updates the todo caches for users with todos on the merge request' do
        create(:todo, target: merge_request, user: user, author: user, project: project)

        expect { service.execute(merge_request) }
          .to change { user.todos_pending_count }.from(1).to(0)
      end

      it_behaves_like 'service deleting todos' do
        let(:issuable) { merge_request }
        let(:other_issuable) { create(:merge_request, target_project: project, source_project: project, author: user, assignees: [user]) }
      end
    end
  end
end

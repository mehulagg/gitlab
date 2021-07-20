# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::UpdateAssigneesService do
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :private, :repository, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:user3) { create(:user) }

  let_it_be_with_reload(:merge_request) do
    create(:merge_request, :simple, :unique_branches,
           assignee_ids: [user.id],
           source_project: project,
           author: user)
  end

  before do
    project.add_maintainer(user)
    project.add_developer(user2)
    project.add_developer(user3)
  end

  let(:service) { described_class.new(project: project, current_user: user, params: opts) }

  describe 'execute' do
    def update_merge_request
      service.execute(merge_request)
      merge_request.reload
    end

    context 'when the parameters are valid' do
      context 'when using sentinel values' do
        let(:opts) { { assignee_ids: [0, 0, 0] } }

        it 'removes all assignees' do
          expect { update_merge_request }.to change(merge_request, :assignees).to([])
        end
      end

      context 'the assignee_ids parameter is the empty list' do
        let(:opts) { { assignee_ids: [] } }

        it 'removes all assignees' do
          expect { update_merge_request }.to change(merge_request, :assignees).to([])
        end
      end

      context 'the assignee_ids parameter contains both zeros and valid IDs' do
        let(:opts) { { assignee_ids: [0, user2.id, 0, user3.id, 0] } }

        it 'ignores 0 IDs' do
          expect { update_merge_request }.to change(merge_request, :assignees).to(match_array([user2, user3]))
        end
      end
    end
  end
end

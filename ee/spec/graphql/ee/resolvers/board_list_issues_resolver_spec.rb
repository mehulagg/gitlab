# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::BoardListIssuesResolver do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:board) { create(:board, project: project) }
  let_it_be(:label) { create(:label, project: project) }
  let_it_be(:list) { create(:list, board: board, label: label) }

  before_all do
    group.add_developer(user)
  end

  describe '#resolve' do
    context 'filtering by epic' do
      let_it_be(:issue) { create(:issue, project: project, labels: [label]) }
      let_it_be(:epic) { create(:epic, group: group) }
      let_it_be(:epic_issue) { create(:epic_issue, epic: epic, issue: issue) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'raises an exception if both epic_id and epic_wildcard_id are present' do
        expect do
          resolve_board_list_issues({ filters: { epic_id: epic.to_global_id, epic_wildcard_id: 'NONE' } })
        end.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end

      it 'accepts epic global id' do
        result = resolve_board_list_issues({ filters: { epic_id: epic.to_global_id } })

        expect(result).to match_array([issue])
      end

      it 'accepts epic wildcard id' do
        result = resolve_board_list_issues({ filters: { epic_wildcard_id: 'NONE' } })

        expect(result).to match_array([])
      end
    end

    context 'filtering by iteration' do
      let_it_be(:iteration) { create(:iteration, group: group) }
      let_it_be(:issue_with_iteration) { create(:issue, project: project, labels: [label], iteration: iteration) }
      let_it_be(:issue_without_iteration) { create(:issue, project: project, labels: [label]) }

      it 'accepts iteration title' do
        result = resolve_board_list_issues({ filters: { iteration_title: iteration.title } })

        expect(result).to contain_exactly(issue_with_iteration)
      end

      it 'accepts iteration wildcard id' do
        result = resolve_board_list_issues({ filters: { iteration_wildcard_id: 'NONE' } })

        expect(result).to contain_exactly(issue_without_iteration)
      end
    end
  end

  def resolve_board_list_issues(args)
    resolve(described_class, obj: list, args: args, ctx: { current_user: user })
  end
end

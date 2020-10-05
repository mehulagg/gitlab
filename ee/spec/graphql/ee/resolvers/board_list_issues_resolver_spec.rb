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
  let_it_be(:issue) { create(:issue, project: project, labels: [label]) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:epic_issue) { create(:epic_issue, epic: epic, issue: issue) }

  describe '#resolve' do
    before do
      stub_licensed_features(epics: true)
      group.add_developer(user)
    end

    it 'raises an exception if both epic_id and epic_wildcard_id are present' do
      expect do
        resolve_board_list_issues({ filters: { epic_id: epic.to_global_id, epic_wildcard_id: 'NONE' } })
      end.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
    end

    it 'accepts epic global id' do
      result = resolve_board_list_issues({ filters: { epic_id: epic.to_global_id } }).items

      expect(result).to match_array([issue])
    end

    it 'accepts epic wildcard id' do
      result = resolve_board_list_issues({ filters: { epic_wildcard_id: 'NONE' } }).items

      expect(result).to match_array([])
    end
  end

  def resolve_board_list_issues(args)
    resolve(described_class, obj: list, args: args, ctx: { current_user: user })
  end
end

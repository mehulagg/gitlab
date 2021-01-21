# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Boards::BoardListEpicsResolver do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:development) { create(:group_label, group: group, name: 'Development') }
  let_it_be(:testing) { create(:group_label, group: group, name: 'Testing') }

  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:list1) { create(:epic_list, epic_board: board, label: development, position: 0) }
  let_it_be(:list2) { create(:epic_list, epic_board: board, label: testing, position: 0) }
  let_it_be(:list1_epic1) { create(:labeled_epic, group: group, labels: [development]) }
  let_it_be(:list1_epic2) { create(:labeled_epic, group: group, labels: [development]) }
  let_it_be(:list2_epic1) { create(:labeled_epic, group: group, labels: [testing]) }

  let_it_be(:epic_pos1) { create(:epic_board_position, epic: list1_epic1, epic_board: board, relative_position: 20) }
  let_it_be(:epic_pos2) { create(:epic_board_position, epic: list1_epic2, epic_board: board, relative_position: 10) }
  let_it_be(:epic_pos3) { create(:epic_board_position, epic: list1_epic1, relative_position: 30) }

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::EpicType.connection_type)
  end

  describe '#resolve' do
    let(:args) { {} }

    subject(:result) { resolve(described_class, ctx: { current_user: user }, obj: list1, args: args) }

    before do
      stub_licensed_features(epics: true)
      group.add_reporter(user)
    end

    it 'returns epics on the board list ordered by position on the board' do
      expect(result.to_a).to eq([list1_epic2, list1_epic1])
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::Epics::ListService do
  describe '#execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:board) { create(:epic_board, group: group) }

    let_it_be(:development) { create(:group_label, group: group, name: 'Development') }
    let_it_be(:testing) { create(:group_label, group: group, name: 'Testing') }

    let_it_be(:backlog) { create(:epic_list, epic_board: board, list_type: :backlog) }
    let_it_be(:list1) { create(:epic_list, epic_board: board, label: development, position: 0) }
    let_it_be(:list2) { create(:epic_list, epic_board: board, label: testing, position: 1) }
    let_it_be(:closed) { create(:epic_list, epic_board: board, list_type: :closed) }

    let_it_be(:backlog_epic1) { create(:epic, group: group) }
    let_it_be(:list1_epic1) { create(:labeled_epic, group: group, labels: [development]) }
    let_it_be(:list1_epic2) { create(:labeled_epic, group: group, labels: [development]) }
    let_it_be(:list1_epic3) { create(:labeled_epic, group: group, labels: [development]) }
    let_it_be(:list2_epic1) { create(:labeled_epic, group: group, labels: [testing]) }

    let_it_be(:closed_epic1) { create(:labeled_epic, :closed, group: group, labels: [development], closed_at: 1.day.ago) }
    let_it_be(:closed_epic2) { create(:labeled_epic, :closed, group: group, labels: [testing], closed_at: 2.days.ago) }
    let_it_be(:closed_epic3) { create(:epic, :closed, group: group, closed_at: 1.week.ago) }

    before do
      stub_licensed_features(epics: true)
      group.add_developer(user)
    end

    it_behaves_like 'items list service' do
      let(:parent) { group }
      let(:backlog_items) { [backlog_epic1] }
      let(:list1_items) { [list1_epic1, list1_epic2, list1_epic3] }
      let(:closed_items) { [closed_epic1, closed_epic2, closed_epic3] }
      let(:all_items) { backlog_items + list1_items + closed_items + [list2_epic1] }
      let(:list_factory) { :epic_list }
      let(:new_list) { create(:epic_list, epic_board: board) }
    end

    it 'returns epics sorted by position on the board' do
      create(:epic_board_position, epic: list1_epic1, epic_board: board, relative_position: 20)
      create(:epic_board_position, epic: list1_epic2, epic_board: board, relative_position: 10)
      create(:epic_board_position, epic: list1_epic1, relative_position: 30)

      epics = described_class.new(group, user, { board_id: board.id, id: list1.id }).execute

      expect(epics).to eq([list1_epic2, list1_epic1, list1_epic3])
    end

    it 'calls the from_id scope' do
      expect(Epic).to receive(:from_id).with(list1_epic2.id).and_call_original

      described_class
        .new(group, user, { board_id: board.id, id: list1.id, from_id: list1_epic2.id })
        .execute
    end
  end
end

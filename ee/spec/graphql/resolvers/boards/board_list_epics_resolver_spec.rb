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

  def resolve_board_list_epics(args: {})
    resolve(described_class, ctx: { current_user: user }, obj: list1, args: args)
  end

  describe '#resolve' do
    subject(:result) { resolve_board_list_epics }

    before do
      stub_licensed_features(epics: true)
      group.add_reporter(user)
    end

    it 'returns epics on the board list ordered by position on the board' do
      expect(result.to_a).to eq([list1_epic2, list1_epic1])
    end

    context 'when filtering' do
      let_it_be(:production_label) { create(:group_label, group: group, name: 'production') }
      let_it_be(:list1_epic3) { create(:labeled_epic, group: group, labels: [development, production_label], title: 'filter_this 1') }
      let_it_be(:list1_epic4) { create(:labeled_epic, group: group, labels: [development], description: 'filter_this 2') }
      let_it_be(:awarded_emoji) { create(:award_emoji, name: 'thumbsup', awardable: list1_epic1, user: user) }

      subject(:results) { resolve(described_class, ctx: { current_user: user }, obj: list1, args: args) }

      context 'by label' do
        let(:args) { { filters: { label_name: [production_label.title] } } }

        it { is_expected.to contain_exactly(list1_epic3) }
      end

      context 'by author' do
        let(:args) { { filters: { author_username: list1_epic4.author.username } } }

        it { is_expected.to contain_exactly(list1_epic4) }
      end

      context 'by reaction emoji' do
        let(:args) { { filters: { my_reaction_emoji: awarded_emoji.name } } }

        it { is_expected.to contain_exactly(list1_epic1) }
      end

      context 'by title and description' do
        let(:args) { { filters: { search: 'filter_this' } } }

        it { is_expected.to contain_exactly(list1_epic3, list1_epic4) }
      end

      context 'with negated filters' do
        context 'by label' do
          let(:args) { { filters: { not: { label_name: [production_label.title] } } } }

          it { is_expected.to contain_exactly(list1_epic1, list1_epic2, list1_epic4) }
        end

        context 'by author' do
          let(:args) { { filters: { not: { author_username: list1_epic2.author.username } } } }

          it { is_expected.to contain_exactly(list1_epic1, list1_epic3, list1_epic4) }
        end

        context 'by emoji' do
          let(:args) { { filters: { not: { my_reaction_emoji: awarded_emoji.name } } } }

          it { is_expected.to contain_exactly(list1_epic2, list1_epic3, list1_epic4) }
        end
      end
    end
  end
end

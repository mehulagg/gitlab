# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Boards::EpicListsResolver do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be_with_refind(:group) { create(:group, :private) }
  let_it_be(:epic_board) { create(:epic_board, group: group) }
  let_it_be(:epic_list1) { create(:epic_list, epic_board: epic_board) }
  let_it_be(:epic_list2) { create(:epic_list, epic_board: epic_board) }

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::Boards::EpicListType.connection_type)
  end

  describe '#resolve' do
    let(:args) { {} }

    subject(:result) { resolve(described_class, ctx: { current_user: user }, obj: epic_board, args: args) }

    before do
      stub_licensed_features(epics: true)
    end

    it 'raises an error if user cannot read epic lists' do
      expect { result }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when user is member of the group' do
      before do
        group.add_reporter(user)
      end

      it 'returns epic lists for the board' do
        expect(result.items).to match_array([epic_list1, epic_list2])
      end

      context 'when list ID param is set' do
        let(:args) { { id: epic_list1.to_global_id } }

        it 'returns an array with single epic list' do
          expect(result.items).to match_array([epic_list1])
        end
      end
    end
  end
end

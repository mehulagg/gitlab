# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Boards::EpicBoardsResolver do
  include GraphqlHelpers

  let_it_be_with_refind(:group) { create(:group) }
  let_it_be(:epic_board1) { create(:epic_board, name: 'fooB', group: group) }
  let_it_be(:epic_board2) { create(:epic_board, name: 'fooA', group: group) }

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::Boards::EpicBoardType.connection_type)
  end

  describe '#resolve' do
    subject(:result) { resolve(described_class, obj: group) }

    context 'when epics are not available' do
      before do
        stub_licensed_features(epics: false)
      end

      it 'returns an empty array' do
        expect(result).to be_empty
      end
    end

    context 'when epics are available' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'returns epic boards in the group ordered by name' do
        expect(result).to match_array([epic_board2, epic_board1])
      end
    end
  end
end

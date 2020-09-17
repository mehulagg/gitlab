# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Boards::EpicUserPreferencesResolver do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:epic) { create(:epic, group: group) }

  describe '#resolve' do
    subject(:preferences) { batch_sync { resolve(described_class, obj: epic, args: {}, ctx: context) } }

    context 'when board is not set' do
      let(:context) { { current_user: user } }

      it 'returns nil' do
        expect(preferences).to be_nil
      end
    end

    context 'when user is not set' do
      let(:context) { { board: board } }

      it 'returns nil' do
        expect(preferences).to be_nil
      end
    end

    context 'when user and board is set' do
      let(:context) { { board: board, current_user: user } }

      it 'returns nil if there are not preferences' do
        expect(preferences).to be_nil
      end

      context 'when user preferences are set' do
        let_it_be(:epic_user_preference) { create(:epic_user_preference, board: board, epic: epic, user: user) }

        it 'returns user preferences' do
          expect(preferences).to eq(epic_user_preference)
        end
      end
    end
  end
end

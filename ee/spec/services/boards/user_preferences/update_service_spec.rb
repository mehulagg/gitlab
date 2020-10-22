# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::UserPreferences::UpdateService, services: true do
  describe '#execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:board) { create(:board) }

    context 'when user is not present' do
      it 'does not create user preference record' do
        service = described_class.new(nil, hide_labels: true)

        result = service.execute(board)

        expect(result).to eq(false)
        expect(board.user_preferences).to be_empty
      end
    end

    context 'when user is present' do
      context 'when there is no user preference' do
        it 'creates user preference' do
          result = described_class.new(user, hide_labels: true).execute(board)

          preferences = board.user_preferences.find_by(user: user)
          expect(preferences.hide_labels).to eq(true)
          expect(result).to eq(true)
        end
      end

      context 'when there is an user preference' do
        let_it_be(:user_preference) { create(:board_user_preference, user: user, hide_labels: true) }
        let_it_be(:board) { user_preference.board }

        it 'does not duplicate user preference' do
          result = described_class.new(user, hide_labels: false).execute(board)

          preferences = board.user_preferences.where(user: user)
          expect(preferences.count).to eq(1)
          expect(preferences.first.hide_labels).to eq(false)
          expect(result).to eq(true)
        end

        it 'does not update user_id' do
          expect { described_class.new(user, user: create(:user)).execute(board) }
            .not_to change { user_preference.reload.user_id }
        end

        it 'does not update board_id' do
          expect { described_class.new(user, board: create(:board)).execute(board) }
            .not_to change { user_preference.reload.board_id }
        end
      end
    end
  end
end

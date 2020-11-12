# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicUserPreference do
  subject { build(:epic_user_preference) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:board) }
    it { is_expected.to belong_to(:epic) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to([:board_id, :epic_id]) }
  end

  describe 'scopes' do
    describe '.for_boards_and_epics' do
      it 'returns user board epic preferences for the given boards and epics' do
        user = create(:user)
        board = create(:board)
        user_pref1 = create(:epic_user_preference, user: user, board: board)
        user_pref2 = create(:epic_user_preference, user: user, board: board)
        user_pref3 = create(:epic_user_preference, board: board, epic: user_pref1.epic)
        create(:epic_user_preference, user: user, board: board)

        result = described_class.for_boards_and_epics(board.id, [user_pref1.epic_id, user_pref2.epic_id])
        expect(result).to match_array([user_pref1, user_pref2, user_pref3])
      end
    end
  end
end

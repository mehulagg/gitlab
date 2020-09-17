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
    describe '.for_user_board_epic_ids' do
      it 'returns user board epic preferences for the user, board and epic ids' do
        user = create(:user)
        board = create(:board)
        user_pref1 = create(:epic_user_preference, user: user, board: board)
        user_pref2 = create(:epic_user_preference, user: user, board: board)
        create(:epic_user_preference, user: user, board: board)

        result = described_class.for_user_board_epic_ids(user, board, [user_pref1.epic_id, user_pref2.epic_id])
        expect(result).to match_array([user_pref1, user_pref2])
      end
    end
  end
end

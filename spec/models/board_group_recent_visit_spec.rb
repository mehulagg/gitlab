require 'spec_helper'

describe BoardGroupRecentVisit do
  let(:user)  { create(:user) }
  let(:group) { create(:group) }
  let(:board) { create(:board, group: group) }

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:board) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:board) }
  end

  describe '#visited' do
    it 'creates a visit if one does not exists' do
      expect { described_class.visited(user, board) }.to change(described_class, :count).by(1)
    end

    it 'updates the timestamp' do
      create :board_group_recent_visit, group: board.group, board: board, user: user, updated_at: 7.days.ago

      Timecop.freeze do
        described_class.visited(user, board)

        expect(described_class.count).to eq 1
        expect(described_class.first.updated_at).to be_like_time(Time.zone.now)
      end
    end
  end

  describe '#latest' do
    it 'returns the most recent visited' do
      board2 = create(:board, group: group)
      board3 = create(:board, group: group)

      create :board_group_recent_visit, group: board.group, board: board, user: user, updated_at: 7.days.ago
      create :board_group_recent_visit, group: board2.group, board: board2, user: user, updated_at: 5.days.ago
      recent = create :board_group_recent_visit, group: board3.group, board: board3, user: user, updated_at: 1.day.ago

      expect(described_class.latest(user, group)).to eq recent
    end
  end
end

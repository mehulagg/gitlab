# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoard do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:epic_board_labels) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
  end

  describe '.order_by_name_asc' do
    let_it_be(:board1) { create(:epic_board, name: 'B') }
    let_it_be(:board2) { create(:epic_board, name: 'a') }
    let_it_be(:board3) { create(:epic_board, name: 'A') }

    it 'returns in case-insensitive alphabetical order and then by ascending id' do
      expect(described_class.order_by_name_asc).to eq [board2, board3, board1]
    end
  end
end

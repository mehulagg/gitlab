# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoardsFinder do
  describe '#execute' do
    let_it_be(:group) { create(:group) }
    let_it_be(:epic_board1) { create(:epic_board, name: 'Acd', group: group) }
    let_it_be(:epic_board2) { create(:epic_board, name: 'abd', group: group) }
    let_it_be(:epic_board3) { create(:epic_board, name: 'Bbd', group: group) }
    let_it_be(:epic_board4) { create(:epic_board) }

    let(:params) { {} }

    subject(:result) { described_class.new(group, params).execute }

    it 'finds all epic boards in the group ordered by case-insensitive name' do
      expect(result).to eq([epic_board2, epic_board1, epic_board3])
    end

    context 'when ID parameter is set' do
      let(:params) { { id: epic_board2.id } }

      it 'finds epic board by ID' do
        expect(result).to eq([epic_board2])
      end
    end
  end
end

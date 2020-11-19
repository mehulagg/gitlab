# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpicBoardPosition do
  let_it_be(:epic) { create(:epic) }
  let_it_be(:group) { create(:group) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:epic_board_position) { create(:epic_board_position, epic: epic, board: board) }

  describe 'associations' do
    subject { build(:epic_board_position) }

    it { is_expected.to belong_to(:epic) }
    it { is_expected.to belong_to(:board) }
  end

  describe 'validations' do
    subject { build(:epic_board_position) }

    it { is_expected.to validate_presence_of(:epic) }
    it { is_expected.to validate_presence_of(:board) }

    specify { expect(subject).to be_valid }

    it 'is valid with nil relative position' do
      subject.relative_position = nil

      expect(subject).to be_valid
    end

    it 'disallows a record with same epic and board' do
      expect(build(:epic_board_position, epic: epic, board: board)).not_to be_valid
    end
  end

  describe 'scopes' do
    describe '.order_relative_position' do
      let(:first) { epic_board_position }
      let(:second) { create(:epic_board_position, board: board, relative_position: RelativePositioning::START_POSITION + 7 ) }

      it 'returns epic_board_positions in order' do
        expect(described_class.order_relative_position).to eq([first, second])
      end
    end
  end

  it_behaves_like "a class that supports relative positioning" do
    let(:factory) { :epic_board_position }
    let(:default_params) { { parent: board } }
  end
end

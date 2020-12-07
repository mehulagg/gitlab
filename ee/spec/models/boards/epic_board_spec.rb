# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoard do
  describe 'associations' do
    it { is_expected.to belong_to(:group).required.inverse_of(:epic_boards) }
    it { is_expected.to have_many(:epic_board_labels).inverse_of(:epic_board) }
    it { is_expected.to have_many(:epic_board_positions).inverse_of(:epic_board) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end
end

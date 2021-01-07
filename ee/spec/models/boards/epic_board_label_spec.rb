# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoardLabel do
  describe 'associations' do
    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_board_labels) }
    it { is_expected.to belong_to(:label).required.inverse_of(:epic_board_labels) }
  end
end

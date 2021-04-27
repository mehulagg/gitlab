# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoardRecentVisit do
  describe 'associations' do
    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_board_recent_visits) }
    it { is_expected.to belong_to(:group).required.inverse_of(:epic_board_recent_visits) }
    it { is_expected.to belong_to(:user).required.inverse_of(:epic_board_recent_visits) }
  end
end

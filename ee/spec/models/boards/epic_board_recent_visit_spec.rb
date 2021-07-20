# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoardRecentVisit do
  let_it_be(:board_parent) { create(:group) }
  let_it_be(:board) { create(:epic_board, group: board_parent) }

  describe 'associations' do
    it { is_expected.to belong_to(:epic_board).required.inverse_of(:epic_board_recent_visits) }
    it { is_expected.to belong_to(:group).required.inverse_of(:epic_board_recent_visits) }
    it { is_expected.to belong_to(:user).required.inverse_of(:epic_board_recent_visits) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:epic_board) }
  end

  it_behaves_like 'boards recent visit' do
    let_it_be(:board_parent_relation) { :group }
    let_it_be(:board_relation) { :epic_board }
    let_it_be(:visit_relation) { :epic_board_recent_visit }
  end
end

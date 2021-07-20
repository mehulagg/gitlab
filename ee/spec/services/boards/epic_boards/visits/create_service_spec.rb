# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoards::Visits::CreateService do
  describe '#execute' do
    let_it_be(:group) { create(:group) }
    let_it_be(:board) { create(:epic_board, group: group) }
    let_it_be(:model) { Boards::EpicBoardRecentVisit }

    context 'with epic board' do
      it_behaves_like 'boards recent visit create service'
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicLists::UpdateService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be_with_reload(:list) { create(:epic_list, epic_board: board, position: 0) }
  let_it_be_with_reload(:list2) { create(:epic_list, epic_board: board, position: 1) }

  before do
    stub_licensed_features(epics: true)
  end

  describe '#execute' do
    let(:service) { described_class.new(board.resource_parent, user, params) }

    context 'when position parameter is present' do
      let(:params) { { position: 1 } }

      it_behaves_like 'moving list'
    end

    context 'when collapsed parameter is present' do
      let(:params) { { collapsed: true } }

      it_behaves_like 'updating list preferences'
    end

    context 'when position and collapsed are both present' do
      let(:params) { { collapsed: true, position: 1 } }

      it_behaves_like 'moving list'
      it_behaves_like 'updating list preferences'
    end
  end
end

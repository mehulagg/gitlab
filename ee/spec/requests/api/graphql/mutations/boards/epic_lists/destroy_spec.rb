# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Destroy an epic board list' do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:epic_board_list) { create(:epic_board_list, epic_board: epic_board) }

  before do
    stub_licensed_features(epics: true)
  end

  it_behaves_like 'board lists destroy request' do
    let(:mutation_name) { :epic_board_list_destroy }
  end
end

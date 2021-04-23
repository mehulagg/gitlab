# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::EpicLists::Update do
  let_it_be(:group)    { create(:group, :private) }
  let_it_be(:board)    { create(:epic_board, group: group) }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:guest)    { create(:user) }
  let_it_be(:list)     { create(:epic_list, epic_board: board, position: 0) }
  let_it_be(:list2)    { create(:epic_list, epic_board: board) }

  before do
    stub_licensed_features(epics: true)
  end

  context 'on epic boards' do
    it_behaves_like 'update board list mutation'
  end
end

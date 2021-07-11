# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicBoards::DestroyService do
  let_it_be(:parent) { create(:group) }

  let(:boards) { parent.epic_boards }
  let(:board_factory) { :epic_board }

  it_behaves_like 'board destroy service'
end

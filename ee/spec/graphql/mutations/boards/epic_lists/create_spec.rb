# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::EpicLists::Create do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:epic_board, group: group) }

  before do
    stub_licensed_features(epics: true)
  end

  it_behaves_like 'board lists create mutation'
end

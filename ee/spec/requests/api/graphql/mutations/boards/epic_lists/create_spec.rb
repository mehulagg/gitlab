# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a label or backlog board list' do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:board) { create(:epic_board, group: group) }
  let_it_be(:current_user)  { create(:user) }

  it_behaves_like 'board lists create request' do
    let(:mutation_name) { :epic_board_list_create }
  end
end

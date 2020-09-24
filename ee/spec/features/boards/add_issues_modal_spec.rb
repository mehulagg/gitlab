# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Boards add issue modal', :js do
  let(:project) { create(:project, :public) }
  let(:board) { create(:board, project: project) }
  let(:user) { create(:user) }

  let!(:label) { create(:label, project: project) }
  let!(:list) { create(:list, board: board, label: label, position: 0) }
  let!(:issue) { create(:issue, project: project, title: 'abc', description: 'def') }

  before do
    project.add_maintainer(user)

    sign_in(user)

    visit project_board_path(project, board)
    wait_for_requests
  end

  it 'shows weight filter' do
    click_button('Add issues')
    wait_for_requests
    find('.add-issues-modal .filtered-search').click

    expect(page.find('.filter-dropdown')).to have_content 'Weight'
  end
end

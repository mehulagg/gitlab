# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project issue boards sidebar milestones', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:project)      { create(:project, :public) }
  let!(:milestone)   { create(:milestone, project: project) }
  let!(:issue1)      { create(:issue, project: project) }
  let(:board)        { create(:board, project: project) }
  let!(:list)        { create(:list, board: board, position: 0) }
  let(:card)         { find('.board:nth-child(1)').first('.board-card') }

  before do
    project.add_maintainer(user)

    sign_in(user)

    visit project_board_path(project, board)
    wait_for_requests
  end

  context 'milestone' do
    it 'adds a milestone' do
      click_card(card)

      page.within('.milestone') do
        click_link 'Edit'

        wait_for_requests

        click_link milestone.title

        wait_for_requests

        page.within('.value') do
          expect(page).to have_content(milestone.title)
        end
      end
    end

    it 'removes a milestone' do
      click_card(card)

      page.within('.milestone') do
        click_link 'Edit'

        wait_for_requests

        click_link "No milestone"

        wait_for_requests

        page.within('.value') do
          expect(page).not_to have_content(milestone.title)
        end
      end
    end
  end
end

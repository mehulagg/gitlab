# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Boards labels', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:project)      { create(:project, :public) }
  let!(:development) { create(:label, project: project, name: 'Development') }
  let!(:bug)         { create(:label, project: project, name: 'Bug') }
  let!(:regression)  { create(:label, project: project, name: 'Regression') }
  let!(:stretch)     { create(:label, project: project, name: 'Stretch') }
  let!(:issue1)      { create(:labeled_issue, project: project, labels: [development], relative_position: 2) }
  let!(:issue2)      { create(:labeled_issue, project: project, labels: [development, stretch], relative_position: 1) }
  let(:board)        { create(:board, project: project) }
  let!(:list)        { create(:list, board: board, label: development, position: 0) }
  let(:card)         { find('.board:nth-child(2)').first('.board-card') }

  before do
    project.add_maintainer(user)

    sign_in(user)

    visit project_board_path(project, board)
    wait_for_requests
  end

  context 'labels' do
    it 'shows current labels when editing' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'

        wait_for_requests

        page.within('.value') do
          expect(page).to have_selector('.gl-label-text', count: 2)
          expect(page).to have_content(development.title)
          expect(page).to have_content(stretch.title)
        end
      end
    end

    it 'adds a single label' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'

        wait_for_requests

        click_link bug.title

        wait_for_requests

        find('.dropdown-menu-close-icon').click

        page.within('.value') do
          expect(page).to have_selector('.gl-label-text', count: 3)
          expect(page).to have_content(bug.title)
        end
      end

      # 'Development' label does not show since the card is in a 'Development' list label
      expect(card).to have_selector('.gl-label', count: 2)
      expect(card).to have_content(bug.title)
    end

    it 'adds a multiple labels' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'

        wait_for_requests

        click_link bug.title

        wait_for_requests

        click_link regression.title

        wait_for_requests

        find('.dropdown-menu-close-icon').click

        page.within('.value') do
          expect(page).to have_selector('.gl-label-text', count: 4)
          expect(page).to have_content(bug.title)
          expect(page).to have_content(regression.title)
        end
      end

      # 'Development' label does not show since the card is in a 'Development' list label
      expect(card).to have_selector('.gl-label', count: 3)
      expect(card).to have_content(bug.title)
      expect(card).to have_content(regression.title)
    end

    it 'removes a label' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'

        wait_for_requests

        within('.dropdown-menu-labels') do
          click_link stretch.title
        end

        wait_for_requests

        find('.dropdown-menu-close-icon').click

        page.within('.value') do
          expect(page).to have_selector('.gl-label-text', count: 1)
          expect(page).not_to have_content(stretch.title)
        end
      end

      # 'Development' label does not show since the card is in a 'Development' list label
      expect(card).to have_selector('.gl-label-text', count: 0)
      expect(card).not_to have_content(stretch.title)
    end

    it 'creates project label' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'
        wait_for_requests

        click_link 'Create project label'
        fill_in 'new_label_name', with: 'test label'
        first('.suggest-colors-dropdown a').click
        click_button 'Create'
        wait_for_requests

        expect(page).to have_link 'test label'
      end
      expect(page).to have_selector('.board', count: 3)
    end

    it 'creates project label and list' do
      click_card(card)

      page.within('.labels') do
        click_link 'Edit'
        wait_for_requests

        click_link 'Create project label'
        fill_in 'new_label_name', with: 'test label'
        first('.suggest-colors-dropdown a').click
        first('.js-add-list').click
        click_button 'Create'
        wait_for_requests

        expect(page).to have_link 'test label'
      end
      expect(page).to have_selector('.board', count: 4)
    end
  end
end

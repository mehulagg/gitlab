# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Boards assignees', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:project)      { create(:project, :public) }
  let!(:development) { create(:label, project: project, name: 'Development') }
  let!(:regression)  { create(:label, project: project, name: 'Regression') }
  let!(:stretch)     { create(:label, project: project, name: 'Stretch') }
  let!(:issue1)      { create(:labeled_issue, project: project, assignees: [user], labels: [development], relative_position: 2) }
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

  context 'assignee' do
    it 'updates the issues assignee' do
      click_card(card)

      page.within('.assignee') do
        click_button('Edit')

        wait_for_requests

        assignee = first('.gl-avatar-labeled').find('.gl-avatar-labeled-label').text

        page.within('.dropdown-menu-user') do
          first('.gl-avatar-labeled').click
        end

        click_button('Edit')
        wait_for_requests

        expect(page).to have_content(assignee)
      end

      expect(card).to have_selector('.avatar')
    end

    it 'removes the assignee' do
      card_two = find('.board:nth-child(2)').find('.board-card:nth-child(2)')
      click_card(card_two)

      page.within('.assignee') do
        click_button('Edit')

        wait_for_requests

        page.within('.dropdown-menu-user') do
          find('[data-testid="unassign"]').click
        end

        click_button('Edit')
        wait_for_requests

        expect(page).to have_content('None')
      end

      expect(card_two).not_to have_selector('.avatar')
    end

    it 'assignees to current user' do
      click_card(card)

      page.within(find('.assignee')) do
        expect(page).to have_content('None')

        click_button 'assign yourself'

        wait_for_requests

        expect(page).to have_content(user.name)
      end

      expect(card).to have_selector('.avatar')
    end

    it 'updates assignee dropdown' do
      click_card(card)

      page.within('.assignee') do
        click_button('Edit')

        wait_for_requests

        assignee = first('.gl-avatar-labeled').find('.gl-avatar-labeled-label').text

        page.within('.dropdown-menu-user') do
          first('.gl-avatar-labeled').click
        end

        click_button('Edit')
        wait_for_requests

        expect(page).to have_content(assignee)
      end

      page.within(find('.board:nth-child(2)')) do
        find('.board-card:nth-child(2)').click
      end

      page.within('.assignee') do
        click_button('Edit')

        expect(find('.dropdown-menu')).to have_selector('.gl-new-dropdown-item-check-icon')
      end
    end
  end
end

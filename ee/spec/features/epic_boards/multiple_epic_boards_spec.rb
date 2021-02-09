# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'epic boards', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }

  let_it_be(:epic_board) { create(:epic_board, group: group) }
  let_it_be(:epic_board2) { create(:epic_board, group: group) }

  context 'multiple epic boards' do
    before do
      stub_licensed_features(epics: true)
      sign_in(user)
      visit_epic_boards_page
    end

    it 'shows current epic board name' do
      page.within('.boards-switcher') do
        expect(page).to have_content(epic_board.name)
      end
    end

    it 'shows a list of epic boards' do
      in_boards_switcher_dropdown do
        expect(page).to have_content(epic_board.name)
        expect(page).to have_content(epic_board2.name)
      end
    end

    it 'switches current epic board' do
      in_boards_switcher_dropdown do
        click_link epic_board2.name
      end

      wait_for_requests

      page.within('.boards-switcher') do
        expect(page).to have_content(epic_board2.name)
      end
    end
  end

  def visit_epic_boards_page
    visit group_epic_boards_path(group)
    wait_for_requests
  end

  def in_boards_switcher_dropdown
    find('.boards-switcher').click

    wait_for_requests

    dropdown_selector = '.js-boards-selector .dropdown-menu'
    page.within(dropdown_selector) do
      yield
    end
  end
end
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Epic boards sidebar', :js do
  include BoardHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }

  let_it_be(:bug) { create(:group_label, group: group, name: 'Bug') }
  let_it_be(:epic_board) { create(:epic_board, group: group) }
  let_it_be(:backlog_list) { create(:epic_list, epic_board: epic_board, list_type: :backlog) }
  let_it_be(:closed_list) { create(:epic_list, epic_board: epic_board, list_type: :closed) }
  let_it_be(:epic1) { create(:epic, group: group, title: 'Epic1') }

  let(:card) { find('.board:nth-child(1)').first("[data-testid='board_card']") }

  before do
    stub_licensed_features(epics: true)
    group.add_maintainer(user)
    sign_in(user)
    visit group_epic_boards_path(group)
    wait_for_requests
  end

  it 'shows sidebar when clicking epic' do
    click_card(card)

    expect(page).to have_selector('[data-testid="epic-boards-sidebar"]')
  end

  it 'closes sidebar when clicking epic' do
    click_card(card)

    expect(page).to have_selector('[data-testid="epic-boards-sidebar"]')

    click_card(card)

    expect(page).not_to have_selector('[data-testid="epic-boards-sidebar"]')
  end

  it 'closes sidebar when clicking close button' do
    click_card(card)

    expect(page).to have_selector('[data-testid="epic-boards-sidebar"]')

    find('[data-testid="close-icon"]').click

    expect(page).not_to have_selector('[data-testid="epic-boards-sidebar"]')
  end

  context 'labels' do
    it 'adds a single label' do
      click_card(card)

      page.within('.labels') do
        click_button 'Edit'

        wait_for_requests

        click_link bug.title

        find('[data-testid="close-icon"]').click

        wait_for_requests

        page.within('.value') do
          expect(page).to have_selector('.gl-label-text', count: 1)
          expect(page).to have_content(bug.title)
        end
      end

      expect(card).to have_selector('.gl-label', count: 1)
      expect(card).to have_content(bug.title)
    end
  end
end

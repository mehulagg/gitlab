# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'epic boards', :js do
  include DragTo
  include MobileHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }

  let_it_be(:epic_board) { create(:epic_board, group: group) }
  let_it_be(:label) { create(:group_label, group: group, name: 'Label1') }
  let_it_be(:label2) { create(:group_label, group: group, name: 'Label2') }
  let_it_be(:label_list) { create(:epic_list, epic_board: epic_board, label: label, position: 0) }
  let_it_be(:backlog_list) { create(:epic_list, epic_board: epic_board, list_type: :backlog) }
  let_it_be(:closed_list) { create(:epic_list, epic_board: epic_board, list_type: :closed) }

  let_it_be(:epic1) { create(:epic, group: group, labels: [label], title: 'Epic1') }
  let_it_be(:epic2) { create(:epic, group: group, title: 'Epic2') }
  let_it_be(:epic3) { create(:epic, group: group, labels: [label2], title: 'Epic3') }

  context 'display epics in board' do
    before do
      stub_licensed_features(epics: true)
      group.add_maintainer(user)
      sign_in(user)
      visit_epic_boards_page
    end

    it 'displays default lists and a label list' do
      lists = %w[Open Label1 Closed]

      wait_for_requests

      expect(page).to have_selector('.board-header', count: 3)

      page.all('.board-header').each_with_index do |list, i|
        expect(list.find('.board-title')).to have_content(lists[i])
      end
    end

    it 'displays two epics in Open list' do
      expect(list_header(backlog_list)).to have_content('2')

      page.within("[data-board-type='backlog']") do
        expect(page).to have_selector('.board-card', count: 2)
        page.within(first('.board-card')) do
          expect(page).to have_content('Epic3')
        end

        page.within('.board-card:nth-child(2)') do
          expect(page).to have_content('Epic2')
        end
      end
    end

    it 'displays one epic in Label list' do
      expect(list_header(label_list)).to have_content('1')

      page.within("[data-board-type='label']") do
        expect(page).to have_selector('.board-card', count: 1)
        page.within(first('.board-card')) do
          expect(page).to have_content('Epic1')
        end
      end
    end

    it 'creates new column for label containing labeled epic' do
      click_button 'Create list'
      wait_for_all_requests

      page.within("[data-testid='board-add-new-column']") do
        find('label', text: label2.title).click
        click_button 'Add'
      end

      wait_for_all_requests

      expect(page).to have_selector('.board', text: label2.title)
      expect(find('.board:nth-child(3) .board-card')).to have_content(epic3.title)
    end

    it 'moves epic between lists' do
      expect(find('.board:nth-child(1)')).to have_content(epic3.title)

      drag(list_from_index: 0, list_to_index: 1)
      wait_for_all_requests

      expect(find('.board:nth-child(1)')).not_to have_content(epic3.title)
      expect(find('.board:nth-child(2)')).to have_content(epic3.title)
    end
  end

  context 'when user can admin epic boards' do
    before do
      stub_licensed_features(epics: true)
      group.add_maintainer(user)
      sign_in(user)
      visit_epic_boards_page
    end

    it "shows 'Create list' button" do
      expect(page).to have_selector('[data-testid="boards-create-list"]')
    end
  end

  context 'when user cannot admin epic boards' do
    before do
      stub_licensed_features(epics: true)
      group.add_guest(user)
      sign_in(user)
      visit_epic_boards_page
    end

    it "does not show 'Create list'" do
      expect(page).not_to have_selector('[data-testid="boards-create-list"]')
    end
  end

  def visit_epic_boards_page
    visit group_epic_boards_path(group)
    wait_for_requests
  end

  def list_header(list)
    find(".board[data-id='gid://gitlab/Boards::EpicList/#{list.id}'] .board-header")
  end

  def drag(selector: '.board-list', list_from_index: 0, from_index: 0, to_index: 0, list_to_index: 0, perform_drop: true)
    # ensure there is enough horizontal space for four lists
    resize_window(2000, 800)

    drag_to(selector: selector,
            scrollable: '#board-app',
            list_from_index: list_from_index,
            from_index: from_index,
            to_index: to_index,
            list_to_index: list_to_index,
            perform_drop: perform_drop)
  end
end

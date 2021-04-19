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

  let(:edit_board) { find('.btn', text: 'Edit board') }
  let(:view_scope) { find('.btn', text: 'View scope') }

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

      click_button 'Select a label'

      page.within(".dropdown-menu") do
        find('label', text: label2.title).click
      end

      click_button 'Add to board'

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

    it 'creates board filtering by one label' do
      create_board_label(label.title)

      expect(page).to have_selector('.board-card', count: 1)
    end

    it 'adds label to board scope and filters epics' do
      label_title = label.title

      update_board_label(label_title)

      aggregate_failures do
        expect(page).to have_selector('.board-card', count: 1)
        expect(page).to have_content('Epic1')
        expect(page).not_to have_content('Epic2')
        expect(page).not_to have_content('Epic3')
      end
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

    it 'can view board scope' do
      view_scope.click

      page.within('.modal') do
        aggregate_failures do
          expect(find('.modal-header')).to have_content('Board scope')
          expect(page).not_to have_content('Board name')
          expect(page).not_to have_link('Edit')
          expect(page).not_to have_button('Edit')
          expect(page).not_to have_button('Save')
          expect(page).not_to have_button('Cancel')
        end
      end
    end
  end

  context 'filtered search' do
    before do
      stub_licensed_features(epics: true)
      stub_feature_flags(boards_filtered_search: true)

      group.add_guest(user)
      sign_in(user)
      visit_epic_boards_page
    end

    it 'can select an Author and Label' do
      page.find('[data-testid="epic-filtered-search"]').click

      page.within('[data-testid="epic-filtered-search"]') do
        click_link 'Author'
        wait_for_requests
        click_link user.name

        click_link 'Label'
        wait_for_requests
        click_link label.title

        expect(page).to have_text("Author = #{user.name} Label = ~#{label.title}")
      end
    end

    it 'can select a Label and filter the board' do
      page.find('[data-testid="epic-filtered-search"]').click

      page.within('[data-testid="epic-filtered-search"]') do
        click_link 'Label'
        wait_for_requests
        click_link label.title

        find('input').native.send_keys(:return)

        wait_for_requests

        expect(page).to have_text(label.title)
        expect(page).not_to have_text(label2.title)
      end
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

  def click_value(filter, value)
    page.within(".#{filter}") do
      click_button 'Edit'

      if value.is_a?(Array)
        value.each { |value| click_link value }
      else
        click_link value
      end
    end
  end

  def click_on_create_new_board
    page.within '.js-boards-selector' do
      find('.dropdown-menu-toggle').click
      wait_for_requests

      click_button 'Create new board'
    end
  end

  def create_board_label(label_title)
    create_board_scope('labels', label_title)
  end

  def create_board_scope(filter, value)
    click_on_create_new_board
    find('#board-new-name').set 'test'

    click_button 'Expand'

    click_value(filter, value)

    click_on_board_modal

    click_button 'Create board'

    wait_for_requests

    expect(page).not_to have_selector('.board-list-loading')
  end

  def update_board_scope(filter, value)
    edit_board.click

    click_value(filter, value)

    click_on_board_modal

    click_button 'Save changes'

    wait_for_requests

    expect(page).not_to have_selector('.board-list-loading')
  end

  def update_board_label(label_title)
    update_board_scope('labels', label_title)
  end

  # Click on modal to make sure the dropdown is closed (e.g. label scenario)
  #
  def click_on_board_modal
    find('.board-config-modal .modal-content').click
  end
end

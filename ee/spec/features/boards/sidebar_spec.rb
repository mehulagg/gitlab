# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Boards', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:user2)        { create(:user) }
  let(:group)        { create(:group) }
  let(:project)      { create(:project, :public, group: group) }
  let!(:milestone)   { create(:milestone, project: project) }
  let!(:development) { create(:label, project: project, name: 'Development') }
  let!(:stretch)     { create(:label, project: project, name: 'Stretch') }
  let!(:issue1)      { create(:labeled_issue, project: project, assignees: [user], milestone: milestone, labels: [development], weight: 3, relative_position: 2) }
  let!(:issue2)      { create(:labeled_issue, project: project, labels: [development, stretch], relative_position: 1) }
  let!(:scoped_label_1) { create(:label, project: project, name: 'Scoped1::Label1') }
  let!(:scoped_label_2) { create(:label, project: project, name: 'Scoped2::Label2') }
  let(:board)        { create(:board, project: project) }
  let!(:list)        { create(:list, board: board, label: development, position: 0) }
  let(:card1) { find('.board:nth-child(2)').find('.board-card:nth-child(2)') }
  let(:card2) { find('.board:nth-child(2)').find('.board-card:nth-child(1)') }

  around do |example|
    Timecop.freeze { example.run }
  end

  before do
    stub_licensed_features(multiple_issue_assignees: true)

    project.add_maintainer(user)
    project.team.add_developer(user2)

    gitlab_sign_in(user)

    visit project_board_path(project, board)
    wait_for_requests
  end

  context 'assignee' do
    it 'updates the issues assignee' do
      click_card(card2)

      page.within('.assignee') do
        click_link 'Edit'

        wait_for_requests

        page.within('.dropdown-menu-user') do
          click_link user.name

          wait_for_requests
        end

        expect(page).to have_content(user.name)
      end

      expect(card2).to have_selector('.avatar')
    end

    it 'adds multiple assignees' do
      click_card(card2)

      page.within('.assignee') do
        click_link 'Edit'

        wait_for_requests

        page.within('.dropdown-menu-user') do
          click_link user.name
          click_link user2.name
        end

        expect(page).to have_content(user.name)
        expect(page).to have_content(user2.name)
      end

      expect(card2.all('.avatar').length).to eq(2)
    end

    it 'removes the assignee' do
      card_two = find('.board:nth-child(2)').find('.board-card:nth-child(2)')
      click_card(card_two)

      page.within('.assignee') do
        click_link 'Edit'

        wait_for_requests

        page.within('.dropdown-menu-user') do
          click_link 'Unassigned'
        end

        find('.dropdown-menu-toggle').click

        wait_for_requests

        expect(find('.qa-assign-yourself')).to have_content('None')
      end

      expect(card_two).not_to have_selector('.avatar')
    end

    it 'assignees to current user' do
      click_card(card2)

      wait_for_requests

      page.within(find('.assignee')) do
        expect(find('.qa-assign-yourself')).to have_content('None')

        click_button 'assign yourself'

        wait_for_requests

        expect(page).to have_content(user.name)
      end

      expect(card2).to have_selector('.avatar')
    end

    it 'updates assignee dropdown' do
      click_card(card2)

      page.within('.assignee') do
        click_link 'Edit'

        wait_for_requests

        page.within('.dropdown-menu-user') do
          click_link user.name

          wait_for_requests
        end

        expect(page).to have_content(user.name)
      end

      page.within(find('.board:nth-child(2)')) do
        find('.board-card:nth-child(2)').click
      end

      page.within('.assignee') do
        click_link 'Edit'

        expect(find('.dropdown-menu')).to have_selector('.is-active')
      end
    end
  end

  context 'epic' do
    before do
      stub_licensed_features(epics: true)
      group.add_owner(user)
      visit project_board_path(project, board)
      wait_for_requests
    end

    context 'when the issue is not associated with an epic' do
      it 'displays `None` for value of epic' do
        click_card(card1)
        wait_for_requests

        expect(find('.js-epic-label').text).to have_content('None')
      end
    end

    context 'when the issue is associated with an epic' do
      let(:epic1)         { create(:epic, group: group, title: 'Foo') }
      let!(:epic2)        { create(:epic, group: group, title: 'Bar') }
      let!(:epic_issue)   { create(:epic_issue, issue: issue1, epic: epic1) }

      it 'displays name of epic and links to it' do
        click_card(card1)
        wait_for_requests

        expect(find('.js-epic-label')).to have_link(epic1.title, href: epic_path(epic1))
      end

      it 'updates the epic associated with the issue' do
        click_card(card1)
        wait_for_requests

        page.within(find('.js-epic-block')) do
          page.find('.sidebar-dropdown-toggle').click
          wait_for_requests

          click_link epic2.title
          wait_for_requests

          expect(page.find('.value')).to have_content(epic2.title)
        end

        # Ensure that boards_store is also updated the epic associated with the issue.
        click_card(card1)
        wait_for_requests

        click_card(card1)
        wait_for_requests

        expect(find('.js-epic-label')).to have_content(epic2.title)
      end
    end
  end

  context 'weight' do
    it 'displays weight async' do
      click_card(card1)
      wait_for_requests

      expect(find('.js-weight-weight-label').text).to have_content(issue1.weight)
    end

    it 'updates weight in sidebar to 1' do
      click_card(card1)
      wait_for_requests

      page.within '.weight' do
        click_link 'Edit'
        find('.block.weight input').send_keys 1, :enter

        page.within '.value' do
          expect(page).to have_content '1'
        end
      end

      # Ensure the request was sent and things are persisted
      visit project_board_path(project, board)
      wait_for_requests

      click_card(card1)
      wait_for_requests

      page.within '.weight' do
        page.within '.value' do
          expect(page).to have_content '1'
        end
      end
    end

    it 'updates weight in sidebar to no weight' do
      click_card(card1)
      wait_for_requests

      page.within '.weight' do
        click_link 'remove weight'

        page.within '.value' do
          expect(page).to have_content 'None'
        end
      end

      # Ensure the request was sent and things are persisted
      visit project_board_path(project, board)
      wait_for_requests

      click_card(card1)
      wait_for_requests

      page.within '.weight' do
        page.within '.value' do
          expect(page).to have_content 'None'
        end
      end
    end

    context 'unlicensed' do
      before do
        stub_licensed_features(issue_weights: false)
        visit project_board_path(project, board)
        wait_for_requests
      end

      it 'hides weight' do
        click_card(card1)
        wait_for_requests

        expect(page).not_to have_selector('.js-weight-weight-label')
      end
    end
  end

  context 'scoped labels' do
    before do
      stub_licensed_features(scoped_labels: true)

      visit project_board_path(project, board)
      wait_for_requests
    end

    it 'adds multiple scoped labels' do
      click_card(card1)

      page.within('.labels') do
        click_link 'Edit'

        wait_for_requests

        click_link scoped_label_1.title

        wait_for_requests

        click_link scoped_label_2.title

        wait_for_requests

        find('.dropdown-menu-close-icon').click

        page.within('.value') do
          expect(page).to have_selector('.gl-label-scoped', count: 2)
          expect(page).to have_content(scoped_label_1.scoped_label_key)
          expect(page).to have_content(scoped_label_1.scoped_label_value)
          expect(page).to have_content(scoped_label_2.scoped_label_key)
          expect(page).to have_content(scoped_label_2.scoped_label_value)
        end
      end
    end

    context 'with scoped label assigned' do
      let!(:issue3) { create(:labeled_issue, project: project, labels: [development, scoped_label_1, scoped_label_2], relative_position: 3) }
      let(:board) { create(:board, project: project) }
      let(:card3) { find('.board:nth-child(2)').find('.board-card:nth-child(1)') }

      before do
        stub_licensed_features(scoped_labels: true)

        visit project_board_path(project, board)
        wait_for_requests
      end

      it 'removes existing scoped label' do
        click_card(card3)

        page.within('.labels') do
          click_link 'Edit'

          wait_for_requests

          click_link scoped_label_2.title

          wait_for_requests

          find('.dropdown-menu-close-icon').click

          page.within('.value') do
            expect(page).to have_selector('.gl-label-scoped', count: 1)
            expect(page).not_to have_content(scoped_label_1.scoped_label_value)
            expect(page).to have_content(scoped_label_2.scoped_label_key)
            expect(page).to have_content(scoped_label_2.scoped_label_value)
          end
        end

        expect(card3).to have_selector('.gl-label-scoped', count: 1)
        expect(card3).not_to have_content(scoped_label_1.scoped_label_key)
        expect(card3).not_to have_content(scoped_label_1.scoped_label_value)
        expect(card3).to have_content(scoped_label_2.scoped_label_key)
        expect(card3).to have_content(scoped_label_2.scoped_label_value)
      end
    end
  end

  context 'when opening sidebars' do
    let(:settings_button) { find('.js-board-settings-button') }

    it 'closes card sidebar when opening settings sidebar' do
      click_card(card1)

      expect(page).to have_selector('.right-sidebar')

      settings_button.click

      expect(page).to have_selector('.js-board-settings-sidebar')
      expect(page).not_to have_selector('.right-sidebar')
    end

    it 'closes settings sidebar when opening card sidebar' do
      settings_button.click

      expect(page).to have_selector('.js-board-settings-sidebar')

      click_card(card1)

      expect(page).to have_selector('.right-sidebar')
      expect(page).not_to have_selector('.js-board-settings-sidebar')
    end
  end
end

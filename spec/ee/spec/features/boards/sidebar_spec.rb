require 'rails_helper'

describe 'Issue Boards', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:user2)        { create(:user) }
  let(:project)      { create(:project, :public) }
  let!(:milestone)   { create(:milestone, project: project) }
  let!(:development) { create(:label, project: project, name: 'Development') }
  let!(:stretch)     { create(:label, project: project, name: 'Stretch') }
  let!(:issue1)      { create(:labeled_issue, project: project, assignees: [user], milestone: milestone, labels: [development], weight: 3, relative_position: 2) }
  let!(:issue2)      { create(:labeled_issue, project: project, labels: [development, stretch], relative_position: 1) }
  let(:board)        { create(:board, project: project) }
  let!(:list)        { create(:list, board: board, label: development, position: 0) }
  let(:card1) { find('.board:nth-child(2)').find('.card:nth-child(2)') }
  let(:card2) { find('.board:nth-child(2)').find('.card:nth-child(1)') }

  around do |example|
    Timecop.freeze { example.run }
  end

  before do
    stub_licensed_features(multiple_issue_assignees: true)

    project.team << [user, :master]
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
      card_two = find('.board:nth-child(2)').find('.card:nth-child(2)')
      click_card(card_two)

      page.within('.assignee') do
        click_link 'Edit'

        wait_for_requests

        page.within('.dropdown-menu-user') do
          click_link 'Unassigned'
        end

        find('.dropdown-menu-toggle').click

        wait_for_requests

        expect(page).to have_content('No assignee')
      end

      expect(card_two).not_to have_selector('.avatar')
    end

    it 'assignees to current user' do
      click_card(card2)

      page.within(find('.assignee')) do
        expect(page).to have_content('No assignee')

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
        find('.card:nth-child(2)').click
      end

      page.within('.assignee') do
        click_link 'Edit'

        expect(find('.dropdown-menu')).to have_selector('.is-active')
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
        click_link '1'

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
        click_link 'Edit'
        click_link 'No Weight'

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
  end
end

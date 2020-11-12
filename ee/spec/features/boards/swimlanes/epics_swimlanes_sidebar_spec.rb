# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'epics swimlanes sidebar', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, group: group) }

  let_it_be(:board) { create(:board, project: project) }
  let_it_be(:list) { create(:list, board: board, position: 0) }
  let_it_be(:epic1) { create(:epic, group: group) }

  let_it_be(:issue1, reload: true) { create(:issue, project: project) }
  let_it_be(:epic_issue1, reload: true) { create(:epic_issue, epic: epic1, issue: issue1) }

  before do
    project.add_maintainer(user)

    stub_licensed_features(epics: true, swimlanes: true)
    sign_in(user)

    visit project_boards_path(project)
    wait_for_requests

    page.within('.board-swimlanes-toggle-wrapper') do
      page.find('.dropdown-toggle').click
      page.find('.dropdown-item', text: 'Epic').click
    end

    wait_for_all_requests
  end

  context 'time tracking' do
    it 'displays time tracking feature with default message' do
      click_first_issue_card

      page.within('[data-testid="time-tracker"]') do
        expect(page).to have_content('Time tracking')
        expect(page).to have_content('No estimate or time spent')
      end
    end

    context 'when only spent time is recorded' do
      before do
        issue1.timelogs.create!(time_spent: 3600, user: user)

        click_first_issue_card
      end

      it 'shows the total time spent only' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_content('Spent: 1h')
          expect(page).not_to have_content('Estimated')
        end
      end
    end

    context 'when only estimated time is recorded' do
      before do
        issue1.update!(time_estimate: 3600)

        click_first_issue_card
      end

      it 'shows the estimated time only' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_content('Estimated: 1h')
          expect(page).not_to have_content('Spent')
        end
      end
    end

    context 'when estimated and spent times are available' do
      before do
        issue1.update!(time_estimate: 3600)
        issue1.timelogs.create!(time_spent: 1800, user: user)

        click_first_issue_card
      end

      it 'shows time tracking progress bar' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_selector('[data-testid="timeTrackingComparisonPane"]')
        end
      end

      it 'shows both estimated and spent time text' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_content('Spent 30m')
          expect(page).to have_content('Est 1h')
        end
      end
    end

    context 'when limitedToHours instance option is turned on' do
      before do
        stub_application_setting(time_tracking_limit_to_hours: true)

        # 3600+3600*24 = 1d 1h or 25h
        issue1.timelogs.create!(time_spent: 3600 + 3600 * 24, user: user)

        click_first_issue_card
      end

      it 'shows the total time spent only' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_content('Spent: 25h')
        end
      end
    end
  end

  def click_first_issue_card
    page.within("[data-testid='board-epic-lane-issues']") do
      first("[data-testid='board_card']").click
    end
  end
end

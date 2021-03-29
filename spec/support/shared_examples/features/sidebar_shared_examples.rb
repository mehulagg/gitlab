# frozen_string_literal: true

RSpec.shared_examples 'issue boards sidebar' do
  include MobileHelpers

  it 'shows sidebar when clicking issue' do
    expect(page).to have_selector('.issue-boards-sidebar')
  end

  it 'shows issue details when sidebar is open' do
    page.within('.issue-boards-sidebar') do
      expect(page).to have_content(issue.title)
      expect(page).to have_content(issue.to_reference)
    end
  end

  context 'when clicking close button' do
    before do
      find("[data-testid='sidebar-drawer'] .gl-drawer-close-button").click
    end

    it 'unhighlights the active issue card' do
      expect(first_card[:class]).not_to include('is-active')
      expect(first_card[:class]).not_to include('multi-select')
    end

    it 'closes sidebar when clicking close button' do
      expect(page).not_to have_selector('.issue-boards-sidebar')
    end
  end

  context 'when clicking issue' do
    it 'closes sidebar' do
      expect(page).to have_selector('.issue-boards-sidebar')

      click_first_issue_card

      live_debug

      expect(page).not_to have_selector('.issue-boards-sidebar')
    end
  end

  context 'in notifications subscription' do
    it 'displays notifications toggle' do
      page.within('[data-testid="sidebar-notifications"]') do
        expect(page).to have_selector('[data-testid="notification-subscribe-toggle"]')
        expect(page).to have_content('Notifications')
        expect(page).not_to have_content('Notifications have been disabled by the project or group owner')
      end
    end

    it 'shows toggle as on then as off as user toggles to subscribe and unsubscribe' do
      toggle = find('[data-testid="notification-subscribe-toggle"]')

      toggle.click

      expect(toggle).to have_css("button.is-checked")

      toggle.click

      expect(toggle).not_to have_css("button.is-checked")
    end

    context 'when notifications have been disabled' do
      before do
        project.update_attribute(:emails_disabled, true)

        refresh_and_click_first_card

        resize_window(1280, 1080)
      end

      it 'displays a message that notifications have been disabled' do
        page.within('[data-testid="sidebar-notifications"]') do
          expect(page).not_to have_selector('[data-testid="notification-subscribe-toggle"]')
          expect(page).to have_content('Notifications have been disabled by the project or group owner')
        end
      end
    end
  end

  context 'in time tracking' do
    it 'displays time tracking feature with default message' do
      page.within('[data-testid="time-tracker"]') do
        expect(page).to have_content('Time tracking')
        expect(page).to have_content('No estimate or time spent')
      end
    end

    context 'when only spent time is recorded' do
      before do
        issue.timelogs.create!(time_spent: 3600, user: user)

        refresh_and_click_first_card
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
        issue.update!(time_estimate: 3600)

        refresh_and_click_first_card
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
        issue.timelogs.create!(time_spent: 1800, user: user)
        issue.update!(time_estimate: 3600)

        refresh_and_click_first_card
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
        # 3600+3600*24 = 1d 1h or 25h
        issue.timelogs.create!(time_spent: 3600 + 3600 * 24, user: user)
        stub_application_setting(time_tracking_limit_to_hours: true)

        refresh_and_click_first_card
      end

      it 'shows the total time spent only' do
        page.within('[data-testid="time-tracker"]') do
          expect(page).to have_content('Spent: 25h')
        end
      end
    end
  end

  def refresh_and_click_first_card
    page.refresh

    wait_for_requests

    first_card.click
  end
end

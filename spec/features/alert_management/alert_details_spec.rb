# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Alert details', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:alert) { create(:alert_management_alert, project: project, status: 'triggered', title: 'Alert') }

  before_all do
    project.add_developer(developer)
  end

  before do
    sign_in(developer)

    visit details_project_alert_management_path(project, alert)
    wait_for_requests
  end

  context 'when a developer+ displays the alert' do
    it 'shows the alert' do
      page.within('.alert-management-details') do
        expect(find('h2')).to have_content(alert.title)
      end
    end

    it 'shows the alert tabs' do
      page.within('.alert-management-details') do
        alert_tabs = find('[data-testid="alertDetailsTabs"]')

        expect(find('h2')).to have_content(alert.title)
        expect(alert_tabs).to have_content('Alert details')
      end
    end

    it 'shows the right sidebar mounted with correct widgets' do
      page.within('.layout-page') do
        sidebar = find('.right-sidebar')

        expect(sidebar).to have_selector('.alert-status')
        expect(sidebar).not_to have_selector('.alert-assignees')
      end
    end
  end
end

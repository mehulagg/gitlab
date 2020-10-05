# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Incident details', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:alert) { create(:alert_management_alert, project: project, status: 'triggered') }

  before_all do
    project.add_developer(developer)
  end

  before do
    sign_in(developer)

    visit project_alert_management_index_path(project)
    wait_for_requests
  end

  context 'when a developer+ displays the alerts list and the alert service is not enabled' do
    it 'shows the empty state by default' do
      expect(page).to have_content('Surface alerts in GitLab')
    end

    it 'shows the filtered search' do
      expect(page).not_to have_selector('.filtered-search-wrapper')
    end

    it 'shows the alert table' do
      expect(page).not_to have_selector('.gl-table')
    end
  end

  context 'when a developer+ displays the alerts list and the alert service is enabled' do
    let_it_be(:alerts_service) do
      create(:alerts_service,
        project: project,
      )
    end

    it 'shows the filtered search' do
      expect(page).to have_selector('.filtered-search-wrapper')
    end

    it 'shows the alert table' do
      expect(page).to have_selector('.gl-table')
    end

    it 'alert page title' do
      expect(page).to have_content('Alerts')
    end
  end
end

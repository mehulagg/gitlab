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

  context 'when a developer+ displays the alerts list' do
    it 'shows the status tabs' do
      expect(page).to have_selector('.gl-tabs')
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

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Incident details', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:incident) { create(:incident, project: project, author: developer, description: 'description') }

  before_all do
    project.add_developer(developer)
  end

  before do
    sign_in(developer)

    visit project_issues_incident_path(project, incident)
    wait_for_requests
  end

  context 'when a developer+ displays the incident' do
    it 'shows the incident' do
      page.within('.issuable-details') do
        expect(find('h2')).to have_content(incident.title)
      end
    end

    it 'does not show design management' do
      expect(page).not_to have_selector('.js-design-management')
    end

    it 'shows the incident tabs' do
      page.within('.issuable-details') do
        incident_tabs = find('[data-testid="incident-tabs"]')

        expect(find('h2')).to have_content(incident.title)
        expect(incident_tabs).to have_content('Summary')
        expect(incident_tabs).to have_content(incident.description)
      end
    end

    it 'shows the right sidebar mounted with type issue' do
      page.within('.layout-page') do
        sidebar = find('.right-sidebar')

        expect(page).to have_selector('.right-sidebar[data-issuable-type="issue"]')
        expect(sidebar).to have_selector('.incident-severity')
        expect(sidebar).to have_selector('.milestone')
      end
    end
  end

  context 'when an issue `issue_type` is edited by a signed in user' do
    it 'shows the issue type selector with the correct details set' do
      page.find('.js-issuable-edit').click

      page.within('.issuable-details') do
        expect(find_button('Incident')).to be_present
      end
    end

    it 'routes the user to the incident details page when the `issue_type` is set to incident' do
      project_path = "/#{project.full_path}"
      page.find('.js-issuable-edit').click

      page.within('.issuable-details') do
        find('.gl-dropdown-toggle', text: 'Incident').click
        find('.gl-new-dropdown-item', text: 'Issue').click
        click_button 'Save changes'

        wait_for_requests

        expect(page).to have_current_path("#{project_path}/-/issues/#{incident.iid}")
      end
    end
  end
end

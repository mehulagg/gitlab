# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Incident details', :js do
  let(:developer) { create(:user) }
  let(:project) { create(:project) }
  let(:incident) { create(:incident, project: project, author: developer) }

  context 'when a developer+ displays the incident' do
    before do
      project.add_developer(developer)
      sign_in(developer)

      visit project_issue_path(project, incident)
      wait_for_requests
    end

    it 'shows the incident' do
      page.within('.issuable-details') do
        expect(find('h2')).to have_content(incident.title)
      end
    end

    it 'does not show design management' do
      expect(page).not_to have_selector('.js-design-management')
    end
  end

  context 'when incident description has xss snippet' do
    before do
      project.add_developer(developer)
      incident.update!(description: '![xss" onload=alert(1);//](a)')

      sign_in(developer)
      visit project_issue_path(project, incident)
    end

    it 'encodes the description to prevent xss incident', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/incident/207951' do
      page.within('.issuable-details .detail-page-description') do
        image = find('img.js-lazy-loaded')

        expect(page).to have_selector('img', count: 1)
        expect(image['onerror']).to be_nil
        expect(image['src']).to end_with('/a')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User searches Incident Management incidents', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:incident) { create(:incident, project: project) }

  before_all do
    project.add_developer(developer)
  end

  before do
    sign_in(developer)

    visit project_incidents_path(project)
    wait_for_requests
  end

  context 'when a developer+ displays the incidents list they can search for an incident' do
    it 'shows the incident table with an incident for a valid search' do
      expect(page).to have_selector('.filtered-search-wrapper')
      find('.gl-filtered-search-term-input').set('title')
      find('.gl-search-box-by-click-search-button').click
      expect(all('tbody tr').count).to be(1)
    end

    it 'shows the an empty table with an invalid search' do
      find('.gl-filtered-search-term-input').set('dsadadasdasdsa')
      find('.gl-search-box-by-click-search-button').click
      expect(page).not_to have_selector('.dropdown-menu-selectable')
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees Scanner profile', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }

  before_all do
    project.add_developer(user)
  end

  before do
    stub_licensed_features(security_on_demand_scans: true)
    sign_in(user)
    live_debug
    visit new_project_security_configuration_dast_profiles_dast_scanner_profile_path(project)
  end

  context 'when form' do
    it 'shows the form' do
      page.within('.js-dast-scanner-profile-form') do
        expect(find('h2')).to have_content("new scanner profile form")
      end
    end
  end
end

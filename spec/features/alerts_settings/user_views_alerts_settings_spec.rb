# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Alert integrations settings form', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:maintainer) { create(:user) }

  before_all do
    project.add_maintainer(maintainer)
  end

  before do
    sign_in(maintainer)

    visit project_settings_operations_path(project, anchor: 'js-alert-management-settings')
    wait_for_requests
  end

  context 'when a maintainer visits the alerts integrations settings' do
    it 'shows the alerts setting form title' do
      page.within('#js-alert-management-settings') do
        expect(find('h3')).to have_content('Alerts')
      end
    end

    it 'shows the alerts setting form' do
      page.within('#js-alert-management-settings') do
        expect(find('.incident-management-list')).to have_content('Current integrations')
        expect(find('.incident-management-list')).to have_content('Integration Name')
      end
    end
  end
end

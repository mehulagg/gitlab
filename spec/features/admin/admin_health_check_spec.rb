require 'spec_helper'

feature "Admin Health Check", :feature, :broken_storage do
  include StubENV

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    sign_in(create(:admin))
  end

  describe '#show' do
    before do
      visit admin_health_check_path
    end

    it 'has a health check access token' do
      page.has_text? 'Health Check'
      page.has_text? 'Health information can be retrieved'

      token = current_application_settings.health_check_access_token

      expect(page).to have_content("Access token is #{token}")
      expect(page).to have_selector('#health-check-token', text: token)
    end

    describe 'reload access token' do
      it 'changes the access token' do
        orig_token = current_application_settings.health_check_access_token
        click_button 'Reset health check access token'

        expect(page).to have_content('New health check access token has been generated!')
        expect(find('#health-check-token').text).not_to eq orig_token
      end
    end
  end

  context 'when services are up' do
    before do
      visit admin_health_check_path
    end

    it 'shows healthy status' do
      expect(page).to have_content('Current Status: Healthy')
    end
  end

  context 'when a service is down' do
    before do
      allow(HealthCheck::Utils).to receive(:process_checks).and_return('The server is on fire')
      visit admin_health_check_path
    end

    it 'shows unhealthy status' do
      expect(page).to have_content('Current Status: Unhealthy')
      expect(page).to have_content('The server is on fire')
    end
  end

  context 'with repository storage failures' do
    before do
      # Track a failure
      Gitlab::Git::Storage::CircuitBreaker.for_storage('broken').perform { nil } rescue nil
      visit admin_health_check_path
    end

    it 'shows storage failure information' do
      hostname = Gitlab::Environment.hostname

      expect(page).to have_content('broken: failed storage access attempt on host:')
      expect(page).to have_content("#{hostname}: 1 of 10 failures.")
    end

    it 'allows resetting storage failures' do
      click_button 'Reset git storage health information'

      expect(page).to have_content('Git storage health information has been reset')
      expect(page).not_to have_content('failed storage access attempt')
    end
  end
end

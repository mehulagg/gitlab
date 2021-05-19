# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Set up group Mattermost slash commands', :js do
  describe 'user visits the mattermost slash command config page' do
    include_context 'group integration activation'

    before do
      stub_mattermost_setting(enabled: true)
      visit_group_integration('Mattermost slash commands')
    end

    it 'shows a help message' do
      expect(page).to have_content("Use this service to perform common")
    end

    it 'shows a token placeholder' do
      token_placeholder = find_field('service_token')['placeholder']

      expect(token_placeholder).to eq('XXxxXXxxXXxxXXxxXXxxXXxx')
    end

    it 'redirects to the integrations page after activating' do
      token = ('a'..'z').to_a.join

      fill_in 'service_token', with: token
      click_save_integration
      click_save_settings_modal

      expect(current_path).to eq(edit_group_settings_integration_path(group, :mattermost_slash_commands))
      expect(page).to have_content('Mattermost slash commands settings saved and active.')
    end
  end
end

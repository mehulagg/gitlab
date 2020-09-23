# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SCIM Token handling', :js do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    group.add_owner(user)
    stub_licensed_features(group_saml: true)
  end

  describe 'group has no existing scim token' do
    before do
      sign_in(user)
      visit group_saml_providers_path(group)
    end

    it 'displays generate token form' do
      expect(page).to have_selector('.js-generate-scim-token-container', visible: true)
      expect(page).to have_selector('.js-scim-token-container', visible: false)

      page.within '.js-generate-scim-token-container' do
        expect(page).to have_content('Generate a SCIM token to set up your System for Cross-Domain Identity Management.')
        expect(page).to have_button('Generate a SCIM token')
      end
    end
  end

  describe 'group has existing scim token' do
    let!(:scim_token) { create(:scim_oauth_access_token, group: group) }

    before do
      sign_in(user)
      visit group_saml_providers_path(group)
    end

    it 'displays the scim form with an obfuscated token' do
      expect(page).to have_selector('.js-generate-scim-token-container', visible: false)
      expect(page).to have_selector('.js-scim-token-container', visible: true)

      page.within '.js-scim-token-container' do
        expect(page).to have_button('reset it.')
        expect(page.find('#scim_token').value).to eq('********************')
        expect(page.find('#scim_endpoint_url').value).to eq(scim_token.as_entity_json[:scim_api_url])
      end
    end
  end
end

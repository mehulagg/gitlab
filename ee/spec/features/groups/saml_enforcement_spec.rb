# frozen_string_literal: true

require 'spec_helper'

describe 'SAML access enforcement' do
  let(:group) { create(:group, :private, name: 'The Group Name') }
  let(:saml_provider) { create(:saml_provider, group: group, enforced_sso: true) }
  let(:identity) { create(:group_saml_identity, saml_provider: saml_provider) }
  let(:user) { identity.user }

  before do
    group.add_guest(user)
    sign_in(user)
  end

  context 'without SAML session' do
    it 'prevents access to group resources' do
      visit group_path(group)

      expect(page).not_to have_content(group.name)
      expect(page).to have_content('Page Not Found')
      #expect(current_path).to eq(new_user_session_path)
    end

    it 'redirects to SAML sign in for that group'
  end

  context 'with active SAML session' do
    before do
      dummy_session = { saml_provider.id => DateTime.now }
      allow_any_instance_of(Gitlab::SessionStore).to receive(:store).and_return(dummy_session)
    end

    it 'allows access to group resources' do
      visit group_path(group)

      expect(page).not_to have_content('Page Not Found')
      expect(page).to have_content(group.name)
      expect(current_path).to eq(group_path(group))
    end
  end
end

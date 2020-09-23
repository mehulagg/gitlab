# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Groups > Members > List members' do
  let(:user1) { create(:user, name: 'John Doe') }
  let(:user2) { create(:user, name: 'Mary Jane') }
  let(:group) { create(:group) }

  before do
    stub_feature_flags(vue_group_members_list: false)
  end

  context 'with Group SAML identity linked for a user' do
    let(:saml_provider) { create(:saml_provider) }
    let(:group) { saml_provider.group }

    before do
      sign_in(user1)
      group.add_developer(user1)
      group.add_guest(user2)
      user2.identities.create!(provider: :group_saml,
                               saml_provider: saml_provider,
                               extern_uid: 'user2@example.com')
    end

    it 'shows user with SSO status badge' do
      visit group_group_members_path(group)

      member = GroupMember.find_by(user: user2, group: group)

      expect(find("#group_member_#{member.id}").find('.badge-info')).to have_content('SAML')
    end
  end

  context 'when user has a "Group Managed Account"' do
    let(:managed_group) { create(:group_with_managed_accounts) }
    let(:managed_user) { create(:user, :group_managed, managing_group: managed_group) }

    before do
      managed_group.add_guest(managed_user)
    end

    it 'shows user with "Managed Account" badge' do
      visit group_group_members_path(managed_group)

      member = GroupMember.find_by(user: managed_user, group: managed_group)

      expect(page).to have_selector("#group_member_#{member.id} .badge-info", text: 'Managed Account')
    end
  end

  context 'with SAML and enforced SSO' do
    let(:saml_provider) { create(:saml_provider, group: group, enabled: true, enforced_sso: true) }
    let(:user3) { create(:user, name: 'Amy with different SAML provider') }
    let(:user4) { create(:user, name: 'Bob without SAML') }
    let(:session) { { active_group_sso_sign_ins: { saml_provider.id => DateTime.now } } }

    before do
      stub_licensed_features(group_saml: true)
      allow(Gitlab::Session).to receive(:current).and_return(session)

      create(:identity, saml_provider: saml_provider, user: user1)

      group.add_owner(user1)
      sign_in(user1)
    end

    it 'returns only users with SAML in autocomplete', :js do
      create(:identity, saml_provider: saml_provider, user: user2)
      create(:identity, user: user3)

      visit group_group_members_path(group)

      wait_for_requests

      find('.select2-container').click

      expect(page).to have_content(user1.name)
      expect(page).to have_content(user2.name)
      expect(page).not_to have_content(user3.name)
      expect(page).not_to have_content(user4.name)
    end
  end
end

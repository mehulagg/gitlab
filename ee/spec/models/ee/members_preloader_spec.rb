# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::MembersPreloader do
  describe '#preload_all' do
    let(:group) { create(:group) }
    let(:saml_provider) { create(:saml_provider, group: group) }

    def group_sso_with_preload(members)
      MembersPreloader.new(members).preload_all
      MembersPresenter.new(members, current_user: nil).map(&:group_sso?)
    end

    it 'preloads SAML identities to avoid N+1 queries in MembersPresenter' do
      member = create(:group_member, group: group)
      create(:group_saml_identity, user: member.user, saml_provider: saml_provider)
      control = ActiveRecord::QueryRecorder.new { group_sso_with_preload([member]) }

      members = create_list(:group_member, 3, group: group)
      create(:group_saml_identity, user: members.first.user, saml_provider: saml_provider)
      create(:group_saml_identity, user: members.last.user, saml_provider: saml_provider)

      expect { group_sso_with_preload(members) }.not_to exceed_query_limit(control)
    end
  end
end

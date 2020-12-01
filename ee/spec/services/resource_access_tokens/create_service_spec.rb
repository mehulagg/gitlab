# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::CreateService do
  subject { described_class.new(user, resource).execute }

  let_it_be(:user) { create(:user) }

  shared_examples 'token creation succeeds' do
    let(:resource) { create(:project, group: group)}

    before do
      resource.add_maintainer(user)
    end

    it 'does not cause an error' do
      response = subject

      expect(response.error?).to be false
    end

    it 'adds the project bot as a member' do
      expect { subject }.to change { resource.members.count }.by(1)
    end

    it 'creates a project bot user' do
      expect { subject }.to change { User.bots.count }.by(1)
    end
  end

  describe '#execute' do
    context 'with enforced group managed account enabled' do
      let(:group) { create(:group_with_managed_accounts, :private) }
      let(:user) { create(:user, :group_managed, managing_group: group) }

      before do
        stub_feature_flags(group_managed_accounts: true)
        stub_licensed_features(group_saml: true)
      end

      it_behaves_like 'token creation succeeds'
    end

    context "for SAML enabled groups" do
      let(:group) { create(:group, :private) }
      let!(:saml_provider) { create(:saml_provider, group: group, enforced_sso: true) }
      let(:identity) { create(:group_saml_identity, saml_provider: saml_provider) }
      let(:user) { identity.user }

      before do
        stub_licensed_features(group_saml: true)
      end

      it_behaves_like 'token creation succeeds'
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::CreateService do
  subject { described_class.new(user, resource).execute }

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:params) { {} }

  shared_examples 'token creation fails' do
    let(:resource) { create(:project, group: group)}

    before do
      resource.add_maintainer(user)
    end

    it 'returns the error' do
      response = subject

      expect(response.error?).to be true
      expect(response.errors).to include("Failed to provide maintainer access")
    end

    it 'does not add the project bot as a member' do
      expect { subject }.not_to change { resource.members.count }
    end

    it 'immediately destroys the bot user if one was created', :sidekiq_inline do
      expect { subject }.not_to change { User.bots.count }
    end
  end

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

    context "when access provisioning fails" do
      let(:group) { create(:group, :private) }
      let(:unpersisted_user) { create(:user, :project_bot) }

      before do
        unpersisted_user.destroy
        allow_next_instance_of(ResourceAccessTokens::CreateService) do |service|
          allow(service).to receive(:create_membership).and_return(unpersisted_user)
        end
      end

      it_behaves_like 'token creation fails'
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::CreateService do
  subject { described_class.new(user, resource).execute }

  let_it_be(:user) { create(:user, current_sign_in_ip: '8.8.8.8') }

  before do
    allow(::Gitlab::Audit::Auditor).to receive(:audit)
  end

  shared_examples 'token creation succeeds' do
    let(:resource) { create(:project, group: group) }

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

    context 'project access token audit events' do
      let(:resource) { create(:project) }

      context 'when project access token is successfully created' do
        before do
          resource.add_maintainer(user)
        end

        it 'logs project access token details' do
          response = subject
          token = response.payload[:access_token]

          message = "Created project access token with token_id: #{token.id} with scopes: #{token.scopes}"

          expect(::Gitlab::Audit::Auditor).to have_received(:audit).with(
            name: 'resource_acess_token_created',
            author: user,
            scope: resource,
            target: token,
            ip_address: '8.8.8.8',
            message: message
          )
        end
      end

      context 'when project access token is unsuccessfully created' do
        context 'with inadequate permissions' do
          before do
            resource.add_developer(user)
          end

          it 'logs the permission error message' do
            subject

            message = 'Attempted to create project access token but failed with message: ' \
                      'User does not have permission to create project access token'

            expect(::Gitlab::Audit::Auditor).to have_received(:audit).with(
              name: 'resource_acess_token_failed',
              author: user,
              scope: resource,
              target: user,
              ip_address: '8.8.8.8',
              message: message
            )
          end
        end

        context "when access provisioning fails" do
          let(:unpersisted_member) { build(:project_member, source: resource, user: user) }

          before do
            allow_next_instance_of(ResourceAccessTokens::CreateService) do |service|
              allow(service).to receive(:create_user).and_return(user)
              allow(service).to receive(:create_membership).and_return(unpersisted_member)
            end

            resource.add_maintainer(user)
          end

          it 'logs the provisioning error message' do
            subject

            message = 'Attempted to create project access token but failed with message: ' \
                      'Could not provision maintainer access to project access token'

            expect(::Gitlab::Audit::Auditor).to have_received(:audit).with(
              name: 'resource_acess_token_failed',
              author: user,
              scope: resource,
              target: user,
              ip_address: '8.8.8.8',
              message: message
            )
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Auth::Ldap::Sync::Groups do
  include LdapHelpers

  let(:adapter) { ldap_adapter }
  let(:group_sync) { described_class.new(proxy(adapter)) }

  describe '#update_permissions' do
    before do
      allow(EE::Gitlab::Auth::Ldap::Sync::Group).to receive(:execute)
      allow(EE::Gitlab::Auth::Ldap::Sync::AdminUsers).to receive(:execute)
      allow(EE::Gitlab::Auth::Ldap::Sync::ExternalUsers).to receive(:execute)

      create_list(:group_with_ldap_group_link, 2)
    end

    after do
      group_sync.update_permissions
    end

    context 'when group_base is not present' do
      before do
        stub_ldap_config(group_base: nil)
      end

      it 'does not call EE::Gitlab::Auth::Ldap::Sync::AdminUsers#execute' do
        expect(EE::Gitlab::Auth::Ldap::Sync::AdminUsers).not_to receive(:execute)
      end

      it 'does not call EE::Gitlab::Auth::Ldap::Sync::ExternalUsers#execute' do
        expect(EE::Gitlab::Auth::Ldap::Sync::ExternalUsers).not_to receive(:execute)
      end
    end

    context 'when group_base is present' do
      context 'and admin_group and external_groups are not present' do
        before do
          stub_ldap_config(group_base: 'dc=example,dc=com')
        end

        it 'calls EE::Gitlab::Auth::Ldap::Sync::Group#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::Group).to receive(:execute).twice
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::AdminUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::AdminUsers).not_to receive(:execute)
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::ExternalUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::ExternalUsers).not_to receive(:execute)
        end
      end

      context 'and admin_group is present' do
        before do
          stub_ldap_config(
            group_base: 'dc=example,dc=com',
            admin_group: 'my-admin-group'
          )
        end

        it 'calls EE::Gitlab::Auth::Ldap::Sync::Group#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::Group).to receive(:execute).twice
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::AdminUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::AdminUsers).to receive(:execute).once
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::ExternalUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::ExternalUsers).not_to receive(:execute)
        end
      end

      context 'and external_groups is present' do
        before do
          stub_ldap_config(
            group_base: 'dc=example,dc=com',
            external_groups: %w(external_group)
          )
        end

        it 'calls EE::Gitlab::Auth::Ldap::Sync::Group#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::Group).to receive(:execute).twice
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::AdminUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::AdminUsers).not_to receive(:execute)
        end

        it 'does not call EE::Gitlab::Auth::Ldap::Sync::ExternalUsers#execute' do
          expect(EE::Gitlab::Auth::Ldap::Sync::ExternalUsers).to receive(:execute).once
        end
      end
    end
  end
end

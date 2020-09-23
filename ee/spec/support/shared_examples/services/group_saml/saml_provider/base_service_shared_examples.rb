# frozen_string_literal: true

RSpec.shared_examples 'base SamlProvider service' do
  let(:params) do
    {
      sso_url: 'https://test',
      certificate_fingerprint: fingerprint,
      enabled: true,
      enforced_sso: true
    }
  end

  let(:fingerprint) { '11:22:33:44:55:66:77:88:99:11:22:33:44:55:66:77:88:99' }

  before do
    stub_licensed_features(group_saml: true)
  end

  it 'updates SAML provider with given params' do
    expect do
      service.execute
      group.reload
    end.to change { group.saml_provider&.sso_url }.to('https://test')
             .and change { group.saml_provider&.certificate_fingerprint }.to(fingerprint)
             .and change { group.saml_provider&.enabled? }.to(true)
             .and change { group.saml_provider&.enforced_sso? }.to(true)
  end
end

RSpec.shared_examples 'SamlProvider service toggles Group Managed Accounts' do
  let(:cleanup_members_service_spy) { spy('GroupSaml::GroupManagedAccounts::CleanUpMembersService') }

  before do
    allow(GroupSaml::GroupManagedAccounts::CleanUpMembersService)
      .to receive(:new).with(current_user, group).and_return(cleanup_members_service_spy)
  end

  context 'when enabling enforced_group_managed_accounts' do
    let(:params) do
      attributes_for(:saml_provider, :enforced_group_managed_accounts)
    end

    before do
      create(:group_saml_identity, user: current_user, saml_provider: saml_provider)
    end

    it 'updates enforced_group_managed_accounts boolean' do
      expect do
        service.execute
        group.reload
      end.to change { group.saml_provider&.enforced_group_managed_accounts? }.to(true)
    end

    it 'cleans up group members' do
      service.execute

      expect(cleanup_members_service_spy).to have_received(:execute)
    end

    context 'when member cleanup flag is turned off' do
      before do
        stub_feature_flags(gma_member_cleanup: false)
      end

      it 'does not invoke cleaning up of group members' do
        service.execute

        expect(cleanup_members_service_spy).not_to have_received(:execute)
      end
    end

    context 'when save fails' do
      let(:params) do
        super().merge(sso_url: 'NOTANURL<>&*^')
      end

      it 'does not trigger members cleanup' do
        service.execute
        expect(cleanup_members_service_spy).not_to have_received(:execute)
      end
    end

    context 'when clean up fails' do
      before do
        allow(cleanup_members_service_spy).to receive(:execute).and_return(false)
      end

      it 'adds an error to saml provider' do
        expect { service.execute }.to change { group.saml_provider && group.saml_provider.errors[:base] }
                                        .to(["Can't remove group members without group managed account"])
      end

      it 'does not change saml_provider' do
        expect do
          service.execute
          group.reload
        end.not_to change { group.saml_provider }
      end
    end

    context 'when owner has not linked SAML yet' do
      before do
        Identity.delete_all
      end

      it 'adds an error warning that the owner must first link SAML' do
        service.execute

        expect(service.saml_provider.errors[:base]).to eq(["Group Owner must have signed in with SAML before enabling Group Managed Accounts"])
      end

      it 'does not attempt member cleanup' do
        service.execute

        expect(cleanup_members_service_spy).not_to have_received(:execute)
      end
    end
  end

  context 'when group managed accounts was enabled beforehand' do
    let(:params) do
      attributes_for(:saml_provider, :enforced_group_managed_accounts)
    end

    before do
      saml_provider.update!(enforced_group_managed_accounts: true)
    end

    it 'does not clean up group members' do
      service.execute

      expect(cleanup_members_service_spy).not_to have_received(:execute)
    end
  end

  context 'when enforced_group_managed_accounts is disabled' do
    before do
      saml_provider.update!(enforced_group_managed_accounts: true)
    end

    let(:params) do
      attributes_for(:saml_provider, enabled: true, enforced_sso: true, enforced_group_managed_accounts: false)
    end

    it 'does not clean up group members' do
      service.execute

      expect(cleanup_members_service_spy).not_to have_received(:execute)
    end
  end
end

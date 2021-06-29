# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ProjectMember do
  it { is_expected.to include_module(EE::ProjectMember) }

  it_behaves_like 'member validations' do
    let(:entity) { create(:project, group: group)}
  end

  context 'validates GMA enforcement' do
    let(:group) { create(:group_with_managed_accounts, :private) }
    let(:entity) { create(:project, namespace: group)}

    before do
      stub_feature_flags(group_managed_accounts: true)
    end

    context 'enforced group managed account enabled' do
      before do
        stub_licensed_features(group_saml: true)
      end

      it 'allows adding a user linked to the GMA account as project member' do
        user = create(:user, :group_managed, managing_group: group)
        member = entity.add_developer(user)

        expect(member).to be_valid
      end

      it 'does not allow adding a user not linked to the GMA account as project member' do
        member = entity.add_developer(create(:user))

        expect(member).not_to be_valid
        expect(member.errors.messages[:user]).to include('is not in the group enforcing Group Managed Account')
      end

      it 'allows adding a project bot' do
        member = entity.add_developer(create(:user, :project_bot))

        expect(member).to be_valid
      end
    end

    context "for SSO enforced groups" do
      let(:group) { create(:group, :private) }
      let!(:saml_provider) { create(:saml_provider, group: group, enforced_sso: true) }
      let(:identity) { create(:group_saml_identity, saml_provider: saml_provider) }

      before do
        stub_licensed_features(group_saml: true)
      end

      it 'allows adding a user linked to the SAML account as project member' do
        sso_user = identity.user
        member = entity.add_developer(sso_user)

        expect(member).to be_valid
      end

      it 'does not allow adding a user not linked to the SAML account as a project member' do
        member = entity.add_developer(create(:user))

        expect(member).not_to be_valid
        expect(member.errors.messages[:user]).to include('is not linked to a SAML account')
      end

      it 'allows adding a project bot' do
        member = entity.add_developer(create(:user, :project_bot))

        expect(member).to be_valid
      end
    end

    context 'enforced group managed account disabled' do
      it 'allows adding any user as project member' do
        member = entity.add_developer(create(:user))

        expect(member).to be_valid
      end
    end

    context 'enforced SSO disabled' do
      it 'allows adding any user as project member' do
        member = entity.add_developer(create(:user))

        expect(member).to be_valid
      end
    end
  end

  describe '#provisioned_by_this_group?' do
    let_it_be(:member) { build(:project_member) }

    subject { member.provisioned_by_this_group? }

    it { is_expected.to eq(false) }
  end
end

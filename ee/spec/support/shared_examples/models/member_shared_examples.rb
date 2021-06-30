# frozen_string_literal: true

RSpec.shared_examples 'member validations' do
  describe 'validations' do
    context 'validates SSO enforcement' do
      let(:user) { create(:user) }
      let(:identity) { create(:group_saml_identity, user: user) }
      let(:group) { identity.saml_provider.group }
      let(:entity) { group }

      context 'enforced SSO enabled' do
        before do
          allow_any_instance_of(SamlProvider).to receive(:enforced_sso?).and_return(true)
        end

        it 'allows adding the group member' do
          member = entity.add_user(user, Member::DEVELOPER)

          expect(member).to be_valid
        end

        it 'does not add the group member' do
          member = entity.add_user(create(:user), Member::DEVELOPER)

          expect(member).not_to be_valid
          expect(member.errors.messages[:user]).to eq(['is not linked to a SAML account'])
        end

        context 'subgroups' do
          let!(:subgroup) { create(:group, parent: group) }

          before do
            entity.update!(group: subgroup) if entity.is_a?(Project)
          end

          it 'does not allow adding a group member with SSO enforced on subgroup' do
            member = entity.add_user(create(:user), ProjectMember::DEVELOPER)

            expect(member).not_to be_valid
            expect(member.errors.messages[:user]).to eq(['is not linked to a SAML account'])
          end
        end
      end

      context 'enforced SSO disabled' do
        it 'allows adding the group member' do
          member = entity.add_user(user, Member::DEVELOPER)

          expect(member).to be_valid
        end
      end
    end
  end
end

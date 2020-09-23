# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IdentityProviderPolicy do
  subject(:policy) { described_class.new(user, :a_provider) }

  describe '#rules' do
    context 'when user is group managed' do
      let(:user) { build_stubbed(:user, :group_managed) }

      it { is_expected.not_to be_allowed(:link) }
      it { is_expected.not_to be_allowed(:unlink) }

      context 'owner is not yet group managed' do
        let_it_be(:identity) { create(:group_saml_identity) }
        let_it_be(:saml_provider) { identity.saml_provider }
        let_it_be(:group) { saml_provider.group }
        let_it_be(:user) { identity.user }

        subject(:policy) { described_class.new(user, saml_provider) }

        before do
          group.add_owner(user)
        end

        context 'no other owners exist' do
          it { is_expected.not_to be_allowed(:unlink) }
        end

        context 'another group owner exists' do
          let_it_be(:second_owner) { create(:user) }

          before do
            group.add_owner(second_owner)
          end

          context 'without sso linked' do
            it { is_expected.not_to be_allowed(:unlink) }
          end

          context 'with sso linked' do
            before do
              create(:group_saml_identity, saml_provider: saml_provider, user: second_owner)
            end

            it { is_expected.to be_allowed(:unlink) }
          end

          context 'managed by the group' do
            let(:second_owner) { create(:user, :group_managed, managing_group: group) }

            it { is_expected.to be_allowed(:unlink) }
          end
        end
      end
    end
  end
end

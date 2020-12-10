# frozen_string_literal: true
require 'spec_helper'

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::User do
  let(:uid) { 1234 }
  let(:saml_provider) { create(:saml_provider) }
  let(:group) { saml_provider.group }
  let(:auth_hash) { OmniAuth::AuthHash.new(uid: uid, provider: 'group_saml', info: info_hash) }
  let(:info_hash) do
    {
      name: generate(:name),
      email: generate(:email)
    }
  end

  subject(:oauth_user) do
    oauth_user = described_class.new(auth_hash)
    oauth_user.saml_provider = saml_provider

    oauth_user
  end

  def create_existing_identity
    create(:group_saml_identity, extern_uid: uid, saml_provider: saml_provider)
  end

  describe '#valid_sign_in?' do
    context 'with matching user for that group and uid' do
      let!(:identity) { create_existing_identity }

      it 'returns true' do
        is_expected.to be_valid_sign_in
      end
    end

    context 'with no matching user identity' do
      it 'returns false' do
        is_expected.not_to be_valid_sign_in
      end
    end
  end

  describe '#find_and_update!' do
    subject(:find_and_update) { oauth_user.find_and_update! }

    context 'with matching user for that group and uid' do
      let!(:identity) { create_existing_identity }

      it 'updates group membership' do
        expect { find_and_update }.to change { group.members.count }.by(1)
      end

      it 'returns the user' do
        expect(find_and_update).to eq identity.user
      end

      it 'does not mark the user as provisioned' do
        expect(find_and_update.provisioned_by_group).to be_nil
      end
    end

    context 'with no matching user identity' do
      context 'when a user does not exist' do
        it 'creates the user' do
          expect { find_and_update }.to change { User.count }.by(1)
        end

        it 'does not confirm the user' do
          is_expected.not_to be_confirmed
        end

        it 'returns the correct user' do
          expect(find_and_update.email).to eq info_hash[:email]
        end

        it 'marks the user as provisioned by the group' do
          expect(find_and_update.provisioned_by_group).to eq group
        end

        it 'creates the user SAML identity' do
          expect { find_and_update }.to change { Identity.count }.by(1)
        end
      end

      context 'when a conflicting user already exists' do
        before do
          create(:user, email: info_hash[:email])
        end

        it 'does not update membership' do
          expect { find_and_update }.not_to change { group.members.count }
        end

        it 'does not return a user' do
          expect(find_and_update).to eq nil
        end
      end
    end
  end

  describe '#bypass_two_factor?' do
    it 'is false' do
      expect(subject.bypass_two_factor?).to eq false
    end
  end
end

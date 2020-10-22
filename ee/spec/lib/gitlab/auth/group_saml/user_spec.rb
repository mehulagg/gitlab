# frozen_string_literal: true
require 'spec_helper'

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::User do
  let(:uid) { 1234 }
  let(:auth_hash) { OmniAuth::AuthHash.new(uid: uid) }
  let(:saml_provider) { create(:saml_provider) }
  let(:group) { saml_provider.group }

  subject { described_class.new(auth_hash, saml_provider) }

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
    context 'with matching user for that group and uid' do
      let!(:identity) { create_existing_identity }

      it 'updates group membership' do
        expect do
          subject.find_and_update!
        end.to change { group.members.count }.by(1)
      end

      it 'returns the user' do
        expect(subject.find_and_update!).to eq identity.user
      end
    end

    context 'with no matching user identity' do
      it 'does nothing' do
        expect(subject.find_and_update!).to eq nil
        expect(group.members.count).to eq 0
      end
    end
  end

  describe '#bypass_two_factor?' do
    it 'is false' do
      expect(subject.bypass_two_factor?).to eq false
    end
  end
end

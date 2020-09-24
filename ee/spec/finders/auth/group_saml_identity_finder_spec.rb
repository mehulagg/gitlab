# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Auth::GroupSamlIdentityFinder do
  let(:uid) { 1234 }
  let!(:identity) { create(:group_saml_identity, extern_uid: uid) }
  let(:saml_provider) { identity.saml_provider }
  let(:auth_hash) { OmniAuth::AuthHash.new(uid: uid) }

  subject { described_class.new(saml_provider, auth_hash) }

  describe '#first' do
    it 'looks up identity by saml_provider and uid' do
      expect(subject.first).to eq identity
    end
  end
end

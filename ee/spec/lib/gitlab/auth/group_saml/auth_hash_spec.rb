# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::AuthHash do
  let(:raw_info_attr) { { group_attribute => %w(Developers Owners) } }
  let(:omniauth_auth_hash) do
    OmniAuth::AuthHash.new(extra: { raw_info: OneLogin::RubySaml::Attributes.new(raw_info_attr) } )
  end

  subject(:saml_auth_hash) { described_class.new(omniauth_auth_hash) }

  describe '#groups' do
    context 'with a lowercase groups attribute' do
      let(:group_attribute) { 'groups' }

      it 'returns array of groups' do
        expect(saml_auth_hash.groups).to eq(%w(Developers Owners))
      end
    end

    context 'with a capitalized Groups attribute' do
      let(:group_attribute) { 'Groups' }

      it 'returns array of groups' do
        expect(saml_auth_hash.groups).to eq(%w(Developers Owners))
      end
    end

    context 'when no groups are present in the auth hash' do
      let(:raw_info_attr) { {} }

      it 'returns an empty array' do
        expect(saml_auth_hash.groups).to match_array([])
      end
    end
  end
end

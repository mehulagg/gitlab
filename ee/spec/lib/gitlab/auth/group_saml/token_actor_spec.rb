# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::TokenActor do
  let(:saml_provider) { create(:saml_provider) }
  let(:group) { saml_provider.group }

  subject { described_class.new(token) }

  context 'valid token' do
    let(:token) { group.saml_discovery_token }

    it 'is valid for the group' do
      expect(subject).to be_valid_for(group)
    end
  end

  context 'invalid token' do
    let(:token) { 'abcdef' }

    it 'is invalid for the group' do
      expect(subject).not_to be_valid_for(group)
    end
  end

  context 'missing token' do
    let(:token) { nil }

    it 'is invalid for the group' do
      expect(subject).not_to be_valid_for(group)
    end
  end

  context 'when geo prevents saml_provider from having a token' do
    let(:token) { nil }
    let(:group) { double(:group, saml_discovery_token: nil) }

    it 'prevents nil token from allowing access' do
      expect(subject).not_to be_valid_for(group)
    end
  end
end

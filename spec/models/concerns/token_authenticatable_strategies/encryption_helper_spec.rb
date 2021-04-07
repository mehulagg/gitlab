# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TokenAuthenticatableStrategies::EncryptionHelper do
  let(:encrypted_token) { described_class.encrypt_token('my-value') }

  describe '.encrypt_token' do
    it 'encrypts token' do
      expect(encrypted_token).not_to eq('my-value')
    end
  end

  describe '.decrypt_token' do
    it 'decrypts token' do
      expect(described_class.decrypt_token(encrypted_token)).to eq('my-value')
    end
  end
end

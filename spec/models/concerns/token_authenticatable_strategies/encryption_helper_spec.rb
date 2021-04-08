# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TokenAuthenticatableStrategies::EncryptionHelper do
  let(:encrypted_token) { described_class.encrypt_token('my-value') }

  describe '.encrypt_token' do
    context 'when dynamic_nonce feture flag is switched on' do
      it 'adds nonce identifier on the beginning' do
        expect(encrypted_token.first).to eq(described_class::DYNAMIC_NONCE_IDENTIFIER)
      end

      it 'adds nonce at the end' do
        nonce = encrypted_token.last(described_class::NONCE_SIZE)

        expect(nonce).to eq(::Digest::SHA256.hexdigest('my-value').bytes.take(described_class::NONCE_SIZE).pack('c*'))
      end

      it 'encrypts token' do
        expect(encrypted_token[1...-described_class::NONCE_SIZE]).not_to eq('my-value')
      end
    end

    context 'when dynamic_nonce feture flag is switched off' do
      before do
        stub_feature_flags(dynamic_nonce: false)
      end

      it 'does not add nonce identifier on the beginning' do
        expect(encrypted_token.first).not_to eq(described_class::DYNAMIC_NONCE_IDENTIFIER)
      end

      it 'does not add nonce in the end' do
        nonce = encrypted_token.last(described_class::NONCE_SIZE)

        expect(nonce).not_to eq(::Digest::SHA256.hexdigest('my-value').bytes.take(described_class::NONCE_SIZE).pack('c*'))
      end

      it 'encrypts token with static iv' do
        token = Gitlab::CryptoHelper.aes256_gcm_encrypt('my-value')

        expect(encrypted_token).to eq(token)
      end
    end
  end

  describe '.decrypt_token' do
    it 'decrypts token' do
      expect(described_class.decrypt_token(encrypted_token)).to eq('my-value')
    end
  end
end

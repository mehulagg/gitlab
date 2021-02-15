# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::VariableSecretKey do
  # it { is_expected.to validate_length_of(:encrypted_secret_key).is_at_most(255) }
  # it { is_expected.to validate_length_of(:encrypted_secret_key_iv).is_at_most(255) }
  # it { is_expected.to validate_uniqueness_of(:encrypted_secret_key_iv) }
  # it { is_expected.to validate_length_of(:encrypted_secret_key_salt).is_at_most(255) }
  # it { is_expected.to validate_length_of(:secret_key_iv).is_at_most(255) }


  describe 'class methods' do
    describe '.generate_secret_key' do
      let(:mock) { double(OpenSSL::Cipher, random_key: 'hello') }

      before do
        expect(OpenSSL::Cipher).to receive(:new).with('aes-256-gcm').and_return(mock)
      end

      it 'calls OpenSSL::Cipher#encrypt before OpenSSL::Cipher#random_key' do
        aggregate_failures do
          expect(mock).to receive(:encrypt).ordered
          expect(mock).to receive(:random_key).ordered
        end

        described_class.generate_secret_key
      end

      it 'base64 encodes the key' do
        aggregate_failures do
          expect(mock).to receive(:encrypt)
          expect(described_class.generate_secret_key).to eq(Base64.encode64(mock.random_key))
        end
      end
    end
  end
end

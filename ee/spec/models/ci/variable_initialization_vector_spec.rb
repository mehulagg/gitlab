# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::VariableInitializationVector do
  subject { create(:ci_variable_initialization_vector) }

  it { is_expected.to validate_presence_of(:variable_id) }
  it { is_expected.to validate_presence_of(:variable_secret_key_id) }

  it { is_expected.to validate_length_of(:initialization_vector).is_at_most(255) }
  it { is_expected.to validate_presence_of(:initialization_vector) }
  it { is_expected.to validate_uniqueness_of(:initialization_vector) }

  describe 'class methods' do
    describe '.generate_initialization_vector' do
      let(:mock) { double(OpenSSL::Cipher, random_iv: 'hello') }

      before do
        expect(OpenSSL::Cipher).to receive(:new).with('aes-256-gcm').and_return(mock)
      end

      it 'calls OpenSSL::Cipher#encrypt before OpenSSL::Cipher#random_iv' do
        aggregate_failures do
          expect(mock).to receive(:encrypt).ordered
          expect(mock).to receive(:random_iv).ordered
        end

        described_class.generate_initialization_vector
      end

      it 'base64 encodes the iv' do
        aggregate_failures do
          expect(mock).to receive(:encrypt)
          expect(described_class.generate_initialization_vector).to eq(Base64.encode64(mock.random_iv))
        end
      end
    end
  end
end

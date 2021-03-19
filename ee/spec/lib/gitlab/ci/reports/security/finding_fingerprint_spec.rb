# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::FindingFingerprint do
  subject { described_class.new(params.with_indifferent_access) }

  let(:params) do
    {
      algorithm_type: 'hash',
      fingerprint_value: 'FINGERPRINT'
    }
  end

  describe '#initialize' do
    context 'when a supported algorithm type is given' do
      it 'allows itself to be created' do
        expect(subject.algorithm_type).to eq(params[:algorithm_type])
        expect(subject.fingerprint_value).to eq(params[:fingerprint_value])
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash representation of the fingerprint' do
      expect(subject.to_h).to eq(
        algorithm_type: params[:algorithm_type],
        fingerprint_sha256: Digest::SHA1.digest(params[:fingerprint_value])
      )
    end
  end

  describe '#valid?' do
    context 'when supported algorithm_type is given' do
      it 'is valid' do
        expect(subject.valid?).to eq(true)
      end
    end

    context 'when an unsupported algorithm_type is given' do
      let(:params) do
        {
          algorithm_type: 'INVALID',
          fingerprint_value: 'FINGERPRINT'
        }
      end

      it 'is not valid' do
        expect(subject.valid?).to eq(false)
      end
    end
  end
end

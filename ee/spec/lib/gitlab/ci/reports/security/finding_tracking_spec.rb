# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::FindingTracking do
  subject { described_class.new(params.with_indifferent_access) }

  let(:params) do
    {
      algorithm_type: 'hash',
      tracking_value: 'TRACKING'
    }
  end

  describe '#initialize' do
    context 'when a supported algorithm type is given' do
      it 'allows itself to be created' do
        expect(subject.algorithm_type).to eq(params[:algorithm_type])
        expect(subject.tracking_value).to eq(params[:tracking_value])
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash representation of the tracking' do
      expect(subject.to_h).to eq(
        algorithm_type: params[:algorithm_type],
        tracking_sha: Digest::SHA1.digest(params[:tracking_value])
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
          tracking_value: 'TRACKING'
        }
      end

      it 'is not valid' do
        expect(subject.valid?).to eq(false)
      end
    end
  end
end

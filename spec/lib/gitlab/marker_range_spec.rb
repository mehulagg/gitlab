# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::MarkerRange do
  subject(:marker_range) { described_class.new(first, last, mode: mode) }

  let(:first) { 1 }
  let(:last) { 10 }
  let(:mode) { nil }

  it { is_expected.to eq(first..last) }

  it 'behaves like a Range' do
    is_expected.to be_kind_of(Range)
  end

  describe '#mode' do
    subject { marker_range.mode }

    it { is_expected.to be_nil }

    context 'when mode is provided' do
      let(:mode) { :deletion }

      it { is_expected.to eq(mode) }
    end
  end
end

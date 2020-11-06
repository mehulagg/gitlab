# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Experimentation::Experiment do
  let(:percentage) { 50 }
  let(:params) do
    {
      tracking_category: 'Category1',
      use_backwards_compatible_subject_index: true
    }
  end

  before do
    feature = double('FeatureFlag', percentage_of_time_value: percentage )
    expect(Feature).to receive(:get).with(:experiment_key_experiment_percentage).and_return(feature)
  end

  describe 'enabled?' do
    subject { described_class.new(:experiment_key, **params).enabled? }

    context 'when percentage is above 0' do
      context 'when on gitlab.com' do
        before do
          allow(Gitlab).to receive(:dev_env_or_com?).and_return(true)
        end

        it { is_expected.to eq(true)}
      end

      context 'when not gitlab.com' do
        before do
          allow(Gitlab).to receive(:dev_env_or_com?).and_return(false)
        end

        it { is_expected.to eq(false)}
      end
    end

    context 'when percentage is 0' do
      let(:percentage) { 0 }

      it { is_expected.to eq(false)}
    end
  end

  describe 'enabled_for_index?' do
    subject { described_class.new(:experiment_key, **params).enabled_for_index?(index) }

    context 'when index is lower than percentage' do
      let(:percentage) { 50 }
      let(:index) { 40 }

      it { is_expected.to eq(true)}
    end

    context 'when index is bigger than percentage' do
      let(:percentage) { 40 }
      let(:index) { 50 }

      it { is_expected.to eq(false)}
    end

    context 'when index is nil' do
      let(:index) { nil }

      it { is_expected.to eq(false)}
    end
  end
end

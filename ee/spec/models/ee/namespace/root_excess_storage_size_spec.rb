# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Namespace::RootExcessStorageSize do
  let(:namespace) { create(:namespace, additional_purchased_storage_size: additional_purchased_storage_size) }
  let(:total_repository_size_excess) { 50.megabytes }
  let(:additional_purchased_storage_size) { 100 }
  let(:model) { described_class.new(namespace) }

  before do
    allow(namespace).to receive(:total_repository_size_excess).and_return(total_repository_size_excess)
  end

  describe '#above_size_limit?' do
    subject { model.above_size_limit? }

    before do
      allow(Gitlab::CurrentSettings).to receive(:automatic_purchased_storage_allocation?) { storage_allocation_enabled }
    end

    context 'when limit enforcement is off' do
      let(:storage_allocation_enabled) { false }

      it { is_expected.to eq(false) }
    end

    context 'when limit enforcement is on' do
      let(:storage_allocation_enabled) { true }

      context 'with feature flag :namespace_storage_limit disabled' do
        before do
          stub_feature_flags(namespace_storage_limit: false)
        end

        context 'when below limit' do
          it { is_expected.to eq(false) }
        end

        context 'when above limit' do
          let(:total_repository_size_excess) { 101.megabytes }

          it { is_expected.to eq(true) }
        end
      end

      context 'with feature flag :additional_repo_storage_by_namespace disabled' do
        before do
          stub_feature_flags(additional_repo_storage_by_namespace: false)
        end

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#usage_ratio' do
    subject { model.usage_ratio }

    it { is_expected.to eq(0.5) }

    context 'when limit is 0' do
      let(:additional_purchased_storage_size) { 0 }

      context 'when current size is greater than 0' do
        it { is_expected.to eq(1) }
      end

      context 'when current size is less than 0' do
        let(:total_repository_size_excess) { 0 }

        it { is_expected.to eq(0) }
      end
    end
  end

  describe '#current_size' do
    subject { model.current_size }

    it { is_expected.to eq(total_repository_size_excess) }
  end

  describe '#limit' do
    subject { model.limit }

    context 'when there is additional purchased storage and a plan' do
      let(:additional_purchased_storage_size) { 10_000 }

      it { is_expected.to eq(10_000.megabytes) }
    end

    context 'when there is no additionl purchased storage' do
      let(:additional_purchased_storage_size) { 0 }

      it { is_expected.to eq(0.megabytes) }
    end
  end

  describe '#enforce_limit?' do
    subject { model.enforce_limit? }

    let(:storage_allocation_enabled) { true }

    before do
      allow(Gitlab::CurrentSettings).to receive(:automatic_purchased_storage_allocation?) { storage_allocation_enabled }
    end

    context 'with application setting is disabled' do
      let(:storage_allocation_enabled) { false }

      it { is_expected.to eq(false) }
    end

    context 'with feature flags (:namespace_storage_limit & :additional_repo_storage_by_namespace) enabled' do
      it { is_expected.to eq(false) }
    end

    context 'with feature flag :namespace_storage_limit disabled' do
      before do
        stub_feature_flags(namespace_storage_limit: false)
      end

      it { is_expected.to eq(true) }
    end

    context 'with feature flag :additional_repo_storage_by_namespace disabled' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: false)
      end

      it { is_expected.to eq(false) }
    end
  end
end

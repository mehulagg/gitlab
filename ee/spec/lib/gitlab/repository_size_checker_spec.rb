# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RepositorySizeChecker do
  let(:current_size) { 0 }
  let(:limit) { 50 }
  let(:total_repository_size_excess) { 0 }
  let(:additional_purchased_storage) { 0 }
  let(:enabled) { true }
  let(:dev_env_or_com) { true }
  let(:namespace_storage_limit_enforced) { true }

  subject do
    described_class.new(
      current_size_proc: -> { current_size },
      limit: limit,
      total_repository_size_excess: total_repository_size_excess,
      additional_purchased_storage: additional_purchased_storage,
      enabled: enabled
    )
  end

  before do
    allow(Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
    allow(Gitlab::CurrentSettings).to receive(:enforce_namespace_storage_limit?).and_return(namespace_storage_limit_enforced)
  end

  describe '#above_size_limit?' do
    context 'when not dev_env_or_com?' do
      let(:dev_env_or_com) { false }

      include_examples 'checker size above limit'
      include_examples 'checker size not over limit'
    end

    context 'when namspace storage limit is not enforced' do
      let(:namespace_storage_limit_enforced) { false }

      include_examples 'checker size above limit'
      include_examples 'checker size not over limit'
    end

    context 'with feature flag :additional_repo_storage_by_namespace enabled' do
      let(:dev_env_or_com) { true }

      context 'when there is available excess storage' do
        it 'returns false' do
          expect(subject.above_size_limit?).to be_falsey
        end
      end

      context 'when size is above the limit and there is no exccess storage' do
        let(:current_size) { 100 }
        let(:total_repository_size_excess) { 20 }
        let(:additional_purchased_storage) { 10 }

        it 'returns true' do
          expect(subject.above_size_limit?).to be_truthy
        end
      end

      it 'returns false when not over the limit' do
        expect(subject.above_size_limit?).to be_falsey
      end
    end

    context 'with feature flag :additional_repo_storage_by_namespace disabled' do
      let(:dev_env_or_com) { true }

      before do
        stub_feature_flags(additional_repo_storage_by_namespace: false)
      end

      include_examples 'checker size above limit'
      include_examples 'checker size not over limit'
    end
  end

  describe '#exceeded_size' do
    context 'with feature flag :additional_repo_storage_by_namespace enabled' do
      context 'when not dev_env_or_com?' do
        let(:dev_env_or_com) { false }

        include_examples 'checker size exceeded'
      end

      context 'when namspace storage limit is not enforced' do
        let(:namespace_storage_limit_enforced) { false }

        include_examples 'checker size exceeded'
      end

      context 'when current size + total repository size excess are below or equal to the limit + additional purchased storage' do
        let(:current_size) { 50 }
        let(:total_repository_size_excess) { 10 }
        let(:additional_purchased_storage) { 10 }

        it 'returns zero' do
          expect(subject.exceeded_size).to eq(0)
        end
      end

      context 'when current size + total repository size excess are over the limit + additional purchased storage' do
        let(:current_size) { 51 }
        let(:total_repository_size_excess) { 10 }
        let(:additional_purchased_storage) { 10 }

        it 'returns zero' do
          expect(subject.exceeded_size).to eq(1)
        end
      end

      context 'when change size will be over the limit' do
        let(:current_size) { 50 }

        it 'returns zero' do
          expect(subject.exceeded_size(1)).to eq(1)
        end
      end

      context 'when change size will not be over the limit' do
        let(:current_size) { 49 }

        it 'returns zero' do
          expect(subject.exceeded_size(1)).to eq(0)
        end
      end
    end

    context 'with feature flag :additional_repo_storage_by_namespace disabled' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: false)
      end

      include_examples 'checker size exceeded'
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RepositorySizeChecker do
  let(:current_size) { 0 }
  let(:limit) { 50 }
  let(:namespace) { build(:namespace, additional_purchased_storage_size: additional_purchased_storage) }
  let(:total_repository_size_excess) { 0 }
  let(:additional_purchased_storage) { 0 }
  let(:enabled) { true }
  let(:gitlab_setting_enabled) { true }

  subject do
    described_class.new(
      current_size_proc: -> { current_size.megabytes },
      limit: limit.megabytes,
      namespace: namespace,
      enabled: enabled
    )
  end

  before do
    allow(Gitlab::CurrentSettings).to receive(:automatic_purchased_storage_allocation?).and_return(gitlab_setting_enabled)

    allow(namespace).to receive(:total_repository_size_excess).and_return(total_repository_size_excess.megabytes)
  end

  shared_examples 'original logic (without size excess and additional storage)' do
    include_examples 'checker size above limit'
    include_examples 'checker size above limit (with additional storage, that would bring it under the limit)'
    include_examples 'checker size not over limit'
  end

  describe '#above_size_limit?' do
    context 'when enabled is false' do
      let(:enabled) { false }

      it 'returns false' do
        expect(subject.above_size_limit?).to eq(false)
      end
    end

    include_examples 'original logic (without size excess and additional storage)'

    context 'when Gitlab app setting for automatic purchased storage allocation is not enabled' do
      let(:gitlab_setting_enabled) { false }

      include_examples 'original logic (without size excess and additional storage)'
    end

    context 'with feature flag :namespace_storage_limit disabled' do
      before do
        stub_feature_flags(namespace_storage_limit: false)
      end

      context 'when there are no locked projects (total repository excess < additional storage)' do
        let(:current_size) { 100 } # current_size > limit
        let(:total_repository_size_excess) { 5 }
        let(:additional_purchased_storage) { 10 }

        it 'returns false' do
          expect(subject.above_size_limit?).to eq(false)
        end
      end

      context 'when there are no locked projects (total repository excess == additional storage)' do
        let(:current_size) { 100 } # current_size > limit
        let(:total_repository_size_excess) { 10 }
        let(:additional_purchased_storage) { 10 }

        it 'returns false' do
          expect(subject.above_size_limit?).to eq(false)
        end
      end

      context 'when there are locked projects (total repository excess > additional storage)' do
        let(:total_repository_size_excess) { 12 }
        let(:additional_purchased_storage) { 10 }

        include_examples 'checker size above limit'
        include_examples 'checker size not over limit'
      end
    end

    context 'with feature flag :additional_repo_storage_by_namespace disabled' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: false)
      end

      include_examples 'original logic (without size excess and additional storage)'
    end
  end

  describe '#exceeded_size' do
    include_examples 'checker size exceeded'

    context 'when Gitlab app setting for automatic purchased storage allocation is not enabled' do
      let(:gitlab_setting_enabled) { false }

      include_examples 'checker size exceeded'
    end

    context 'with feature flag :namespace_storage_limit disabled' do
      before do
        stub_feature_flags(namespace_storage_limit: false)
      end

      context 'with additional purchased storage' do
        let(:total_repository_size_excess) { 10 }
        let(:additional_purchased_storage) { 10 }

        context 'when current size + total repository size excess are below or equal to the project\'s limit (no need for additional purchase storage)' do
          let(:current_size) { 50 }

          it 'returns zero' do
            expect(subject.exceeded_size).to eq(0)
          end
        end

        context 'when there is remaining storage (current size + excess for other projects need to use additional purchased storage but not all of it)' do
          let(:current_size) { 51 }

          it 'returns 0' do
            expect(subject.exceeded_size).to eq(0)
          end
        end

        context 'when there storage is exceeded (current size + excess for other projects exceed additional purchased storage' do
          let(:total_repository_size_excess) { 15 }
          let(:current_size) { 61 }

          it 'returns 1' do
            expect(subject.exceeded_size).to eq(5.megabytes)
          end
        end
      end

      context 'without additional purchased storage' do
        context 'when change size will be over the limit' do
          let(:current_size) { 50 }

          it 'returns 1' do
            expect(subject.exceeded_size(1.megabytes)).to eq(1.megabytes)
          end
        end

        context 'when change size will not be over the limit' do
          let(:current_size) { 49 }

          it 'returns zero' do
            expect(subject.exceeded_size(1.megabytes)).to eq(0)
          end
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

# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ApplicationSettingChecker::PumaRuggedChecker do
  describe '#check' do
    subject { described_class.check }

    shared_examples 'did not find suboptimal config' do
      it 'returns empty array' do
        expect(subject).to eq([])
      end
    end

    context 'application is not puma' do
      before do
        Object.send(:remove_const, :Puma) if Object.constants.index(:Puma)
      end

      it_behaves_like 'did not find suboptimal config'
    end

    context 'application is puma' do
      before do
        module Puma
        end

        allow(::Puma).to receive_message_chain(:cli_config, :options).and_return(max_threads: puma_max_threads)
        allow(::Gitlab::ApplicationSettingChecker::RuggedDetector).to receive(:rugged_enabled?).and_return(rugged_enabled)
      end

      context 'puma max_threads is 1 and rugged API enabled' do
        let(:puma_max_threads) { 1 }
        let(:rugged_enabled) { true }

        it_behaves_like 'did not find suboptimal config'
      end

      context 'puma max_threads is 1 and rugged API is not enabled' do
        let(:puma_max_threads) { 1 }
        let(:rugged_enabled) { false }

        it_behaves_like 'did not find suboptimal config'
      end

      context 'puma max_threads > 1 and rugged API is enabled' do
        let(:puma_max_threads) { 4 }
        let(:rugged_enabled) { true }
        let(:suboptimal_config_item) do
          {
            category: "performance",
            description: "When Rugged enabled, Puma threads > 1 will lead to performance issue.",
            suggestion: "Change Puma.rb, set new workers to `current_workers * threads_per_worker`",
            title: "puma threads > 1 && rugged enabled",
            extra_data: {
              puma_config: "Puma.cli_config.options[:max_threads] = 4",
              rugged_enabled: true
            }
          }
        end

        it 'returns one suboptimal config issue' do
          expect(subject).to eq([suboptimal_config_item])
        end
      end

      context 'puma max_threads > 1 and rugged API is not enabled' do
        let(:puma_max_threads) { 4 }
        let(:rugged_enabled) { false }

        it_behaves_like 'did not find suboptimal config'
      end
    end
  end
end

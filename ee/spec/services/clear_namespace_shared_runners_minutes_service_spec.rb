# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClearNamespaceSharedRunnersMinutesService do
  include AfterNextHelpers

  describe '#execute' do
    subject { described_class.new(namespace).execute }

    context 'when project has namespace_statistics' do
      let(:namespace) { create(:namespace, :with_used_build_minutes_limit) }

      it 'clears counters' do
        subject

        expect(namespace.namespace_statistics.reload.shared_runners_seconds).to eq(0)
      end

      it 'resets timer' do
        subject

        expect(namespace.namespace_statistics.reload.shared_runners_seconds_last_reset).to be_like_time(Time.current)
      end

      it 'successfully clears minutes' do
        expect(subject).to be_truthy
      end

      it 'expires the CachedQuota' do
        expect_next(Gitlab::Ci::Minutes::CachedQuota).to receive(:expire!)

        subject
      end
    end

    context 'when project does not have namespace_statistics' do
      let(:namespace) { create(:namespace) }

      it 'successfully clears minutes' do
        expect(subject).to be_truthy
      end
    end
  end
end

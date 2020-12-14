# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::VerificationTimeoutWorker, :geo do
  let(:replicable_name) { 'widget' }
  let(:replicator_class) { double('widget_replicator_class') }

  it 'uses a Geo queue' do
    expect(described_class.new.sidekiq_options_hash).to include(
      'queue' => 'geo:geo_verification_timeout',
      'queue_namespace' => :geo
    )
  end

  describe '#perform' do
    before do
      allow(::Gitlab::Geo::Replicator).to receive(:for_replicable_name).with(replicable_name).and_return(replicator_class)

      # This stub is not relevant to the test defined below. This stub is needed
      # for another example defined in `include_examples 'an idempotent
      # worker'`.
      allow(replicator_class).to receive(:fail_verification_timeouts)
    end

    include_examples 'an idempotent worker' do
      let(:job_args) { replicable_name }

      it 'calls fail_verification_timeouts' do
        expect(replicator_class).to receive(:fail_verification_timeouts).exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times

        subject
      end
    end
  end
end

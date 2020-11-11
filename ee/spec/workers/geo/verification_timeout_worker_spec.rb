# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::VerificationTimeoutWorker, :geo do
  let(:replicable_name) { 'widget' }
  let(:replicator_class) { double('widget_replicator_class') }

  subject(:job) { described_class.new }

  it 'uses a Geo queue' do
    expect(job.sidekiq_options_hash).to include(
      'queue' => 'geo:geo_verification_timeout',
      'queue_namespace' => :geo
    )
  end

  describe '#perform' do
    it 'calls fail_verification_timeouts' do
      allow(::Gitlab::Geo::Replicator).to receive(:for_replicable_name).with(replicable_name).and_return(replicator_class)

      expect(replicator_class).to receive(:fail_verification_timeouts)

      job.perform(replicable_name)
    end
  end
end

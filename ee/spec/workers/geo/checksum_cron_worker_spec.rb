# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ChecksumCronWorker, :geo do
  describe '#perform' do
    it 'calls enqueue_checksum_batch_worker on enabled Replicators' do
      replicator = double('replicator')

      expect(replicator).to receive(:enqueue_checksum_batch_worker)
      expect(Gitlab::Geo).to receive(:enabled_replicator_classes).and_return([replicator])

      described_class.new.perform
    end
  end

  it 'uses a cronjob queue' do
    expect(subject.sidekiq_options_hash).to include(
      'queue' => 'cronjob:geo_checksum_cron',
      'queue_namespace' => :cronjob
    )
  end
end

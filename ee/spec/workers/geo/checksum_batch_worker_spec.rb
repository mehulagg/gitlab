# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ChecksumBatchWorker, :geo do
  include ExclusiveLeaseHelpers
  include EE::GeoHelpers

  let(:replicator_class) { double('replicator_class') }
  let(:perform) { job.perform(replicator_class) }
  let(:node) { double('node') }

  before do
    stub_current_geo_node(node)
  end

  subject(:job) { described_class.new }

  it 'uses a Geo queue' do
    expect(job.sidekiq_options_hash).to include(
      'queue' => 'geo:geo_checksum_batch',
      'queue_namespace' => :geo
    )
  end

  describe '#perform' do
    it 'calls batch_calculate_checksum' do
      allow(node).to receive(:verification_max_capacity).and_return(1)
      allow(replicator_class).to receive(:remaining_checksum_batch_count).and_return(1)

      expect(replicator_class).to receive(:batch_calculate_checksum)

      perform
    end
  end

  describe '#remaining_work_count' do
    it 'returns remaining_checksum_batch_count' do
      expected = 7
      args = { max_batch_count: 95 }
      allow(job).to receive(:remaining_capacity).and_return(args[:max_batch_count])

      expect(replicator_class).to receive(:remaining_checksum_batch_count).with(args).and_return(expected)

      expect(job.remaining_work_count(replicator_class)).to eq(expected)
    end
  end

  describe '#max_running_jobs' do
    it 'returns half of verification_max_capacity' do
      allow(node).to receive(:verification_max_capacity).and_return(123)

      expect(job.max_running_jobs).to eq(61)
    end
  end
end

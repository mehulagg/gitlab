# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ReverificationBatchWorker, :geo do
  include EE::GeoHelpers

  let(:replicable_name) { 'widget' }
  let(:replicator_class) { double('widget_replicator_class') }
  let(:node) { double('node') }

  before do
    stub_current_geo_node(node)

    allow(::Gitlab::Geo::Replicator)
      .to receive(:for_replicable_name).with(replicable_name).and_return(replicator_class)
  end

  subject(:job) { described_class.new }

  it 'uses a Geo queue' do
    expect(job.sidekiq_options_hash).to include(
      'queue' => 'geo:geo_reverification_batch',
      'queue_namespace' => :geo
    )
  end

  describe '#perform' do
    it 'calls reverify_batch!' do
      allow(replicator_class).to receive(:remaining_reverification_batch_count).and_return(1)

      expect(replicator_class).to receive(:reverify_batch!)

      job.perform(replicable_name)
    end
  end

  describe '#remaining_work_count' do
    it 'returns remaining_reverification_batch_count' do
      expected = 7
      args = { max_batch_count: 95 }
      allow(job).to receive(:remaining_capacity).and_return(args[:max_batch_count])

      expect(replicator_class).to receive(:remaining_reverification_batch_count).with(args).and_return(expected)

      expect(job.remaining_work_count(replicable_name)).to eq(expected)
    end
  end
end

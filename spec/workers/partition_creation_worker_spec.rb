# frozen_string_literal: true

require "spec_helper"

RSpec.describe PartitionCreationWorker do
  describe '#perform' do
    subject { described_class.new.perform }

    let(:manager) {  instance_double('PartitionManager', create_partitions: nil) }
    let(:monitoring) { instance_double('PartitionMonitoring', report_metrics: nil) }

    before do
      allow(Gitlab::Database::Partitioning::PartitionManager).to receive(:new).and_return(manager)
      allow(Gitlab::Database::Partitioning::PartitionMonitoring).to receive(:new).and_return(monitoring)
    end

    it 'delegates to PartitionCreator' do
      expect(manager).to receive(:create_partitions)

      subject
    end

    it 'reports partition metrics' do
      expect(monitoring).to receive(:report_metrics)

      subject
    end
  end
end

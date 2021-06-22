# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StuckCiJobsWorker do
  include ExclusiveLeaseHelpers

  let(:worker_lease_key) { StuckCiJobsWorker::EXCLUSIVE_LEASE_KEY }
  let(:worker_lease_uuid) { SecureRandom.uuid }

  subject(:worker) { described_class.new }

  before do
    stub_exclusive_lease(worker_lease_key, worker_lease_uuid)
  end

  describe '#perform' do
    it 'executes the drop service' do
      expect_next_instance_of(Ci::StuckBuilds::DropService) do |service|
        expect(service).to receive(:execute)
      end

      worker.perform
    end
  end

  describe 'exclusive lease' do
    let(:worker2) { described_class.new }

    it 'is guarded by exclusive lease when executed concurrently' do
      expect(worker).to receive(:remove_lease).at_least(:once).and_call_original
      expect(worker2).not_to receive(:remove_lease)

      worker.perform

      stub_exclusive_lease_taken(worker_lease_key)

      worker2.perform
    end

    it 'can be executed in sequence' do
      expect(worker).to receive(:remove_lease).at_least(:once).and_call_original
      expect(worker2).to receive(:remove_lease).at_least(:once).and_call_original

      worker.perform
      worker2.perform
    end

    it 'cancels exclusive leases after worker perform' do
      expect_to_cancel_exclusive_lease(worker_lease_key, worker_lease_uuid)

      worker.perform
    end
  end
end

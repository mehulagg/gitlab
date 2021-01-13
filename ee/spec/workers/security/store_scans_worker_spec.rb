# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreScansWorker do
  let_it_be(:sast_scan) { create(:security_scan, scan_type: :sast) }
  let_it_be(:sast_pipeline) { sast_scan.pipeline }
  let_it_be(:sast_build) { sast_pipeline.security_scans.sast.last&.build }

  describe '#perform' do
    subject(:run_worker) { described_class.new.perform(sast_pipeline.id) }

    before do
      allow(Security::StoreScansService).to receive(:execute)
      allow_next_found_instance_of(Ci::Pipeline) do |record|
        allow(record).to receive(:can_store_security_reports?).and_return(can_store_security_reports)
      end
    end

    context 'when security reports can not be stored for the pipeline' do
      let(:can_store_security_reports) { false }

      it 'does not call `Security::StoreScansService`' do
        run_worker

        expect(Security::StoreScansService).not_to have_received(:execute)
      end
    end

    context 'when security reports can be stored for the pipeline' do
      let(:can_store_security_reports) { true }

      it 'calls `Security::StoreScansService`' do
        run_worker

        expect(Security::StoreScansService).to have_received(:execute)
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreScansWorker do
  let_it_be(:secret_detection_scan) { create(:security_scan, scan_type: :secret_detection) }
  let_it_be(:pipeline) { secret_detection_scan.pipeline }

  describe '#revoke_secret_detection_token?' do
    using RSpec::Parameterized::TableSyntax

    where(:secret_detection_build, :token_revocation_enabled, :secret_detection_vulnerability_found, :expected_result) do
      Object.new  | true  | true  | true
      Object.new  | true  | false | false
      Object.new  | false | true  | false
      Object.new  | false | false | false
      nil         | true  | true  | false
      nil         | true  | false | false
      nil         | false | true  | false
      nil         | false | false | false
    end

    with_them do
      before do
        stub_application_setting(secret_detection_token_revocation_enabled: token_revocation_enabled)

        allow_next_instance_of(described_class) do |build_finished_worker|
          allow(build_finished_worker).to receive(:secret_detection_vulnerability_found?) { secret_detection_vulnerability_found }
        end
      end

      specify { expect(described_class.new.send(:revoke_secret_detection_token?, secret_detection_build)).to eql(expected_result) }
    end
  end

  describe '#perform' do
    subject(:run_worker) { described_class.new.perform(pipeline.id) }

    before do
      allow(Security::StoreScansService).to receive(:execute)
      allow_next_found_instance_of(Ci::Pipeline) do |record|
        allow(record).to receive(:can_store_security_reports?).and_return(can_store_security_reports)
      end

      allow(::ScanSecurityReportSecretsWorker).to receive(:perform_async).and_return(nil)
      allow_next_instance_of(described_class) do |store_scans_worker|
        allow(store_scans_worker).to receive(:revoke_secret_detection_token?) { true }
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

      it 'scans security reports for token revocation' do
        expect(::ScanSecurityReportSecretsWorker).to receive(:perform_async)

        run_worker
      end
    end
  end
end

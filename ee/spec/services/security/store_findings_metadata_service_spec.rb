# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreFindingsMetadataService do
  let_it_be(:security_scan) { create(:security_scan) }
  let_it_be(:project) { security_scan.project }
  let_it_be(:security_finding) { build(:ci_reports_security_finding) }
  let_it_be(:security_scanner) { build(:ci_reports_security_scanner) }
  let_it_be(:report) do
    build(
      :ci_reports_security_report,
      findings: [security_finding],
      scanners: [security_scanner]
    )
  end

  describe '#execute' do
    let(:service_object) { described_class.new(security_scan, report) }

    subject(:store_findings) { service_object.execute }

    context 'when the given security scan already has findings' do
      before do
        create(:security_finding, scan: security_scan)
      end

      it 'does not create new findings in database' do
        expect { store_findings }.not_to change { Security::Finding.count }
      end
    end

    context 'when the given security scan does not have any findings' do
      before do
        security_scan.findings.delete_all
      end

      it 'creates the security finding entries in database' do
        expect { store_findings }.to change { security_scan.findings.count }.by(1)
                                 .and change { security_scan.findings.last&.severity }.to(security_finding.severity.to_s)
                                 .and change { security_scan.findings.last&.confidence }.to(security_finding.confidence.to_s)
                                 .and change { security_scan.findings.last&.project_fingerprint }.to(security_finding.project_fingerprint)
      end

      context 'when the scanners already exist in the database' do
        before do
          create(:vulnerabilities_scanner, project: project, external_id: security_scanner.key)
        end

        it 'does not create new scanner entries in the database' do
          expect { store_findings }.not_to change { Vulnerabilities::Scanner.count }
        end
      end

      context 'when the scanner does not exist in the database' do
        it 'creates new scanner entry in the database' do
          expect { store_findings }.to change { project.vulnerability_scanners.count }.by(1)
        end
      end
    end
  end
end

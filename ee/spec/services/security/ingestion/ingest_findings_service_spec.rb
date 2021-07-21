# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Ingestion::IngestFindingsService do
  describe '#execute' do
    let_it_be(:artifact) { create(:ee_ci_job_artifact, :sast) }
    let_it_be(:security_scan) { create(:security_scan, scan_type: :sast, build: artifact.job) }
    let_it_be(:report_findings) { security_scan.report_findings }
    let_it_be(:existing_finding) { create(:vulnerabilities_finding, :detected, uuid: report_findings.first.uuid) }
    let_it_be(:identifiers_map) do
      {
        'fe2eb9d1f6915d533124034338c99dfab1190a77' => create(:vulnerabilities_identifier).id,
        '50c895ade6e732c5dad1df945c86e93619c937d5' => create(:vulnerabilities_identifier).id,
        '04f07307d47fa07491e04bb85e77c8f157c0bf5e' => create(:vulnerabilities_identifier).id,
        '07748c0a1f47320ce46b0b29badc3959d4891407' => create(:vulnerabilities_identifier).id,
        'f5724386167705667ae25a1390c0a516020690ba' => create(:vulnerabilities_identifier).id,
        '5848739446034d982ef7beece3bb19bff4044ffb' => create(:vulnerabilities_identifier).id
      }
    end

    subject(:ingest_findings) { described_class.new(security_scan, identifiers_map).execute }

    before(:all) do
      report_findings.each do |report_finding|
        create(:security_finding,
               scan: security_scan,
               uuid: report_finding.uuid,
               deduplicated: true)
      end
    end

    it 'ingests findings' do
      expect { ingest_findings }.to change { Vulnerabilities::Finding.count }.by(4)
    end

    it 'returns the findings `uuid` to `id` and `vulnerability_id` map' do
      expect(ingest_findings).to match({
        report_findings[0].uuid => [existing_finding.id, existing_finding.vulnerability_id],
        report_findings[1].uuid => [anything, nil],
        report_findings[2].uuid => [anything, nil],
        report_findings[3].uuid => [anything, nil],
        report_findings[4].uuid => [anything, nil],
      })
    end
  end
end

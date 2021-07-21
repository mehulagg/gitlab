# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Ingestion::IngestIdentifiersService do
  describe '#execute' do
    let_it_be(:artifact) { create(:ee_ci_job_artifact, :with_exceeding_identifiers) }
    let_it_be(:security_scan) { create(:security_scan, scan_type: :sast, build: artifact.job) }
    let_it_be(:report_identifier_fingerprints) { security_scan.report_findings.flat_map(&:identifiers).map(&:fingerprint).uniq }
    let_it_be(:service_object) { described_class.new(security_scan) }
    let_it_be(:project_identifiers) { artifact.project.vulnerability_identifiers }
    let_it_be(:existing_identifier) do
      create(:vulnerabilities_identifier,
             project: artifact.project,
             fingerprint: report_identifier_fingerprints.first,
             name: 'foo')
    end

    subject(:ingest_identifiers) { service_object.execute }

    it 'creates new records and updates the existing ones' do
      expect { ingest_identifiers }.to change { project_identifiers.count }.by(19)
                                   .and change { existing_identifier.reload.name }
    end

    it 'it returns all the updated and created identifiers' do
      expect(ingest_identifiers).to eq(project_identifiers.index_by(&:fingerprint).transform_values(&:id))
    end
  end
end

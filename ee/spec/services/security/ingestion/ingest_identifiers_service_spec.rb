# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Ingestion::IngestIdentifiersService do
  describe '#execute' do
    let(:artifact) { create(:ee_ci_job_artifact, :with_exceeding_identifiers) }
    let(:security_scan) { create(:security_scan, scan_type: :sast, build: artifact.job) }
    let(:service_object) { described_class.new(security_scan) }
    let(:existing_identifier) do
      create(:vulnerabilities_identifier,
             project: artifact.project,
             fingerprint: '96c2aec43b4aa1a170ad922f2283d11d0e2b57cf',
             name: 'foo')
    end

    subject(:ingest_identifiers) { service_object.execute }

    it 'creates new records and updates the existing ones' do
      expect { ingest_identifiers }.to change { Vulnerabilities::Identifier.count }.by(19)
                                   .and change { existing_identifier.reload.name }
    end
  end
end

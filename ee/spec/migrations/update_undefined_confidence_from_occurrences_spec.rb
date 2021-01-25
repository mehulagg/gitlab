# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe UpdateUndefinedConfidenceFromOccurrences, :migration do
  let(:vulnerabilities) { table(:vulnerability_occurrences) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:projects) { table(:projects) }
  let(:vul1) { attributes_for(:vulnerabilities_finding, id: 1, report_type: 2, confidence: 5) } # rubocop: disable RSpec/FactoriesInMigrationSpecs

  let(:vul2) { attributes_for(:vulnerabilities_finding, id: 2, report_type: 2, confidence: 5) } # rubocop: disable RSpec/FactoriesInMigrationSpecs

  before do
    stub_const("#{described_class}::BATCH_SIZE", 2)
  end

  it 'updates confidence levels for container scanning reports', :sidekiq_might_not_need_inline do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(true)

    projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab')

    identifiers.create!(id: 1,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c2',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    identifiers.create!(id: 2,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c3',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    scanners.create!(id: 6, project_id: 123, external_id: 'clair', name: 'Security Scanner')

    vulnerabilities.create!(id: vul1[:id],
                            confidence: 0,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: vul1[:project_fingerprint],
                            location_fingerprint: vul1[:location_fingerprint],
                            uuid: vul1[:uuid],
                            name: vul1[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul1[:raw_metadata])

    vulnerabilities.create!(id: vul2[:id],
                            confidence: 2,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 2,
                            project_fingerprint: vul2[:project_fingerprint],
                            location_fingerprint: vul2[:location_fingerprint],
                            uuid: vul2[:uuid],
                            name: vul2[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul2[:raw_metadata])

    expect(vulnerabilities.where(confidence: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(confidence: 0)).to be_falsy
  end

  it 'skips migration for ce' do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(false)

    projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab')

    identifiers.create!(id: 1,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c2',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    scanners.create!(id: 6, project_id: 123, external_id: 'clair', name: 'Security Scanner')

    vulnerabilities.create!(id: vul1[:id],
                            confidence: 0,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: vul1[:project_fingerprint],
                            location_fingerprint: vul1[:location_fingerprint],
                            uuid: vul1[:uuid],
                            name: vul1[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul1[:raw_metadata])

    expect(vulnerabilities.where(confidence: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(confidence: 0)).to be_truthy
  end
end

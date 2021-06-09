# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe UpdateOccurrenceSeverityColumn do
  let(:vulnerabilities) { table(:vulnerability_occurrences) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:projects) { table(:projects) }
  let(:location_fingerprint) { '4e5b6966dd100170b4b1ad599c7058cce91b57b4' }

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

    scanners.create!(id: 6, project_id: 123, external_id: 'trivy', name: 'Security Scanner')

    vulnerabilities.create!(severity: 0,
                            confidence: 5,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: Digest::SHA1.hexdigest(SecureRandom.uuid),
                            location_fingerprint: location_fingerprint,
                            uuid: SecureRandom.uuid,
                            name: 'Cipher with no integrity',
                            metadata_version: '1.3',
                            raw_metadata: '{}')

    vulnerabilities.create!(severity: 2,
                            confidence: 5,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 2,
                            project_fingerprint: Digest::SHA1.hexdigest(SecureRandom.uuid),
                            location_fingerprint: location_fingerprint,
                            uuid: SecureRandom.uuid,
                            name: 'Cipher with no integrity',
                            metadata_version: '1.3',
                            raw_metadata: '{}')

    expect(vulnerabilities.where(severity: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(severity: 0)).to be_falsy
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

    scanners.create!(id: 6, project_id: 123, external_id: 'trivy', name: 'Security Scanner')

    vulnerabilities.create!(severity: 0,
                            confidence: 5,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: generate(:project_fingerprint),
                            location_fingerprint: location_fingerprint,
                            uuid: SecureRandom.uuid,
                            name: 'Cipher with no integrity',
                            metadata_version: '1.3',
                            raw_metadata: '{}')

    expect(vulnerabilities.where(severity: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(severity: 0)).to be_truthy
  end
end

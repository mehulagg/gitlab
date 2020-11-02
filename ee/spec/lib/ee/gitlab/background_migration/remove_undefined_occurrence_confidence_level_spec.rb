# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::RemoveUndefinedOccurrenceConfidenceLevel, :migration, schema: 20200506085748 do
  let(:vulnerabilities) { table(:vulnerability_occurrences) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:projects) { table(:projects) }

  it 'updates undefined Confidence level to unknown' do
    projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab')

    (1..3).to_a.each do |identifier_id|
      identifiers.create!(id: identifier_id,
                          project_id: 123,
                          fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c' + identifier_id.to_s,
                          external_type: 'SECURITY_ID',
                          external_id: 'SECURITY_0',
                          name: 'SECURITY_IDENTIFIER 0')
    end

    scanners.create!(id: 6, project_id: 123, external_id: 'clair', name: 'Security Scanner')

    vul1 = vulnerabilities.create!(vuln_params(1))
    vulnerabilities.create!(vuln_params(2))
    vul3 = vulnerabilities.create!(vuln_params(3).merge(confidence: 2))

    expect(vulnerabilities.where(confidence: 2).count). to eq(1)

    described_class.new.perform(vul1.id, vul3.id)

    expect(vulnerabilities.where(confidence: 2).count).to eq(3)
  end

  def vuln_params(primary_identifier_id)
    attrs = attributes_for(:vulnerabilities_occurrence)

    {
      confidence: 0,
      severity: 5,
      report_type: 2,
      project_id: 123,
      scanner_id: 6,
      primary_identifier_id: primary_identifier_id,
      project_fingerprint: attrs[:project_fingerprint],
      location_fingerprint: attrs[:location_fingerprint],
      uuid: attrs[:uuid],
      name: attrs[:name],
      metadata_version: '1.3',
      raw_metadata: attrs[:raw_metadata]
    }
  end
end

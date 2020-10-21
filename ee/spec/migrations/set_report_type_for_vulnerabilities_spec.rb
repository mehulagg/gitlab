# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe SetReportTypeForVulnerabilities do
  let(:confidence_levels) do
    { undefined: 0, ignore: 1, unknown: 2, experimental: 3, low: 4, medium: 5, high: 6, confirmed: 7 }
  end

  let(:severity_levels) { { undefined: 0, info: 1, unknown: 2, low: 4, medium: 5, high: 6, critical: 7 } }
  let(:report_types) { { sast: 0, dependency_scanning: 1, container_scanning: 2, dast: 3 } }

  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:vulnerabilities) { table(:vulnerabilities) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:findings) { table(:vulnerability_occurrences) }

  def fingerprint
    hash = String.new('', capacity: 40)
    40.times { hash << rand(16).to_s(16) }
    hash
  end

  def bin_fingerprint
    [fingerprint].pack('H*')
  end

  before do
    author = users.create!(id: 1, projects_limit: 10)

    namespace = namespaces.create!(id: 1, name: 'namespace_1', path: 'namespace_1', owner_id: author.id)

    project = projects.create!(id: 1, creator_id: author.id, namespace_id: namespace.id)

    vulnerabilities_common_attrs = { project_id: project.id, author_id: author.id, severity: severity_levels[:high],
                                     confidence: confidence_levels[:medium], report_type: nil }

    vulnerability_1 =
      vulnerabilities.create!(id: 1, title: 'finding_1', title_html: 'finding_1', **vulnerabilities_common_attrs)
    vulnerability_2 =
      vulnerabilities.create!(id: 2, title: 'finding_2', title_html: 'finding_2', **vulnerabilities_common_attrs)
    vulnerabilities.create!(id: 3, title: 'orphan', title_html: 'orphan', **vulnerabilities_common_attrs)

    identifiers_common_attrs = { project_id: project.id, external_type: 'SECURITY_ID' }

    identifier_1 =
      identifiers.create!(id: 1, fingerprint: '1111111111111111111111111111111111111111', external_id: 'SECURITY_1',
                          name: 'SECURITY_IDENTIFIER 1', **identifiers_common_attrs)
    identifier_2 =
      identifiers.create!(id: 2, fingerprint: '2222222222222222222222222222222222222222', external_id: 'SECURITY_2',
                          name: 'SECURITY_IDENTIFIER 2', **identifiers_common_attrs)
    identifier_3 =
      identifiers.create!(id: 3, fingerprint: '3333333333333333333333333333333333333333', external_id: 'SECURITY_3',
                          name: 'SECURITY_IDENTIFIER 3', **identifiers_common_attrs)
    identifier_4 =
      identifiers.create!(id: 4, fingerprint: '4444444444444444444444444444444444444444', external_id: 'SECURITY_4',
                          name: 'SECURITY_IDENTIFIER 4', **identifiers_common_attrs)

    scanner = scanners.create!(id: 1, project_id: project.id, name: 'scanner', external_id: 'SCANNER_ID')

    findings_common_attrs =
      { project_id: project.id, scanner_id: scanner.id, severity: severity_levels[:high],
        confidence: confidence_levels[:medium], metadata_version: 'sast:1.0', raw_metadata: '{}' }

    findings.create!(
      id: 1, report_type: report_types[:sast], name: 'finding_1', primary_identifier_id: identifier_1.id,
      uuid: fingerprint[0..35], vulnerability_id: vulnerability_1.id, project_fingerprint: bin_fingerprint,
      location_fingerprint: bin_fingerprint, **findings_common_attrs)
    findings.create!(
      id: 2, report_type: report_types[:dependency_scanning], name: 'finding_1_extra',
      primary_identifier_id: identifier_2.id, uuid: fingerprint[0..35], vulnerability_id: vulnerability_1.id,
      project_fingerprint: bin_fingerprint, location_fingerprint: bin_fingerprint, **findings_common_attrs)
    findings.create!(
      id: 3, report_type: report_types[:container_scanning], name: 'finding_2', primary_identifier_id: identifier_3.id,
      uuid: fingerprint[0..35], vulnerability_id: vulnerability_2.id, project_fingerprint: bin_fingerprint,
      location_fingerprint: bin_fingerprint, **findings_common_attrs)
    findings.create!(
      id: 4, report_type: report_types[:dast], name: 'finding_orphan', primary_identifier_id: identifier_4.id,
      uuid: fingerprint[0..35], project_fingerprint: bin_fingerprint, location_fingerprint: bin_fingerprint,
      **findings_common_attrs)
  end

  describe '#up' do
    it 'updates vulnerabilities.report_type from their first linked findings' do
      expect(vulnerabilities.all).to all have_attributes(report_type: nil)

      migrate!

      expect(vulnerabilities.find(1).report_type).to eq(findings.find(1).report_type)
      expect(vulnerabilities.find(2).report_type).to eq(findings.find(3).report_type)
    end

    it 'sets the default report_type for orphan vulnerabilities' do
      expect(vulnerabilities.all).to all have_attributes(report_type: nil)

      migrate!

      expect(vulnerabilities.find(3).report_type).to eq report_types[:sast]
    end
  end

  describe '#down' do
    it 'rolls back the vulnerabilities.report_type to NULL values' do
      migrate!

      expect(vulnerabilities.find(1).report_type).to eq(findings.find(1).report_type)
      expect(vulnerabilities.find(2).report_type).to eq(findings.find(3).report_type)
      expect(vulnerabilities.find(3).report_type).to eq report_types[:sast]

      schema_migrate_down!

      expect(vulnerabilities.all).to all have_attributes(report_type: nil)
    end
  end
end

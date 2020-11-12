# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe SetResolvedStateOnVulnerabilities do
  let(:confidence_levels) do
    { undefined: 0, ignore: 1, unknown: 2, experimental: 3, low: 4, medium: 5, high: 6, confirmed: 7 }
  end

  let(:severity_levels) { { undefined: 0, info: 1, unknown: 2, low: 4, medium: 5, high: 6, critical: 7 } }
  let(:states) { { opened: 1, closed: 2, resolved: 3 } }
  let(:report_types) { { sast: 0, dependency_scanning: 1, container_scanning: 2, dast: 3 } }
  let(:feedback_types) { { dismissal: 0, issue: 1 } }

  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:findings) { table(:vulnerability_occurrences) }
  let(:vulnerabilities) { table(:vulnerabilities) }
  let(:issues) { table(:issues) }
  let(:feedbacks) { table(:vulnerability_feedback) }

  let(:vulnerability_open_id) { 1 }
  let(:vulnerability_resolved_id) { 2 }
  let(:vulnerability_dismissed_id) { 3 }
  let(:vulnerability_orphan_id) { 4 }
  let(:vulnerability_non_dismissal_feedback_id) { 5 }

  let(:closer_id) { 2 }

  def fingerprint
    hash = String.new('', capacity: 40)
    40.times { hash << rand(16).to_s(16) }
    hash
  end

  def bin_fingerprint
    [fingerprint].pack(PACK_FORMAT)
  end

  def bin_to_str_fingerprint(bin_data)
    bin_data.unpack1(PACK_FORMAT)
  end

  before do
    stub_const('PACK_FORMAT', 'H*')

    author = users.create!(id: 1, email: 'author@example.com', projects_limit: 10)
    closer = users.create!(id: closer_id, email: 'closer@example.com', projects_limit: 10)
    namespace = namespaces.create!(id: 1, name: 'namespace_1', path: 'namespace_1', owner_id: author.id)
    project = projects.create!(id: 1, creator_id: author.id, namespace_id: namespace.id)

    vulnerabilities_common_attrs = { project_id: project.id, author_id: author.id, severity: severity_levels[:high],
                                     confidence: confidence_levels[:medium], report_type: report_types[:sast] }

    vulnerability_open = vulnerabilities.create!(
      id: vulnerability_open_id, state: states[:opened], title: 'finding_open', title_html: 'finding_open', **vulnerabilities_common_attrs)
    vulnerability_resolved = vulnerabilities.create!(
      id: vulnerability_resolved_id, state: states[:closed], title: 'finding_resolved', title_html: 'finding_resolved', closed_by_id: closer.id,
      **vulnerabilities_common_attrs)
    vulnerability_dismissed = vulnerabilities.create!(
      id: vulnerability_dismissed_id, state: states[:closed], title: 'finding_dismissed', title_html: 'finding_dismissed',
      closed_by_id: closer.id, **vulnerabilities_common_attrs)
    vulnerabilities.create!(
      id: vulnerability_orphan_id, state: states[:closed], title: 'vulnerability_orphan', title_html: 'vulnerability_orphan',
      closed_by_id: closer.id, **vulnerabilities_common_attrs)
    vulnerability_non_dismissal_feedback = vulnerabilities.create!(
      id: vulnerability_non_dismissal_feedback_id, state: states[:closed], title: 'finding_non_dismissal_feedback',
      title_html: 'finding_non_dismissal_feedback', closed_by_id: closer.id, **vulnerabilities_common_attrs)

    scanner = scanners.create!(id: 1, project_id: project.id, name: 'scanner', external_id: 'SCANNER_ID')

    identifiers_common_attrs = { project_id: project.id, external_type: 'SECURITY_ID' }

    identifier_1 = identifiers.create!(
      id: 1, fingerprint: '1111111111111111111111111111111111111111', external_id: 'SECURITY_1',
      name: 'SECURITY_IDENTIFIER 1', **identifiers_common_attrs)

    identifier_2 = identifiers.create!(
      id: 2, fingerprint: '2222222222222222222222222222222222222222', external_id: 'SECURITY_2',
      name: 'SECURITY_IDENTIFIER 2', **identifiers_common_attrs)

    identifier_3 = identifiers.create!(
      id: 3, fingerprint: '3333333333333333333333333333333333333333', external_id: 'SECURITY_3',
      name: 'SECURITY_IDENTIFIER 3', **identifiers_common_attrs)

    identifier_4 = identifiers.create!(
      id: 4, fingerprint: '4444444444444444444444444444444444444444', external_id: 'SECURITY_4',
      name: 'SECURITY_IDENTIFIER 4', **identifiers_common_attrs)

    findings_common_attrs = { project_id: project.id, scanner_id: scanner.id, severity: severity_levels[:high],
                              confidence: confidence_levels[:medium], metadata_version: 'sast:1.0', raw_metadata: '{}' }

    findings.create!(
      id: 1, report_type: report_types[:sast], name: 'finding_confirmed', primary_identifier_id: identifier_1.id,
      uuid: fingerprint[0..35], project_fingerprint: bin_fingerprint, location_fingerprint: bin_fingerprint,
      vulnerability_id: vulnerability_open.id, **findings_common_attrs)

    findings.create!(
      id: 2, report_type: report_types[:dependency_scanning], name: 'finding_resolved',
      primary_identifier_id: identifier_2.id, uuid: fingerprint[0..35], project_fingerprint: bin_fingerprint,
      location_fingerprint: bin_fingerprint, vulnerability_id: vulnerability_resolved.id, **findings_common_attrs)

    finding_dismissed = findings.create!(
      id: 3, report_type: report_types[:container_scanning], name: 'finding_dismissed',
      primary_identifier_id: identifier_3.id, uuid: fingerprint[0..35], project_fingerprint: bin_fingerprint,
      location_fingerprint: bin_fingerprint, vulnerability_id: vulnerability_dismissed.id, **findings_common_attrs)

    finding_non_dismissal_feedback = findings.create!(
      id: 4, report_type: report_types[:dast], name: 'finding_non_dismissal_feedback',
      primary_identifier_id: identifier_4.id, uuid: fingerprint[0..35], project_fingerprint: bin_fingerprint,
      location_fingerprint: bin_fingerprint, vulnerability_id: vulnerability_non_dismissal_feedback.id,
      **findings_common_attrs)

    issue = issues.create!(id: 1, title: 'Fix the vulnerability', project_id: project.id, author_id: author.id)

    feedbacks.create!(
      id: 1, project_id: project.id, author_id: author.id, category: finding_dismissed.report_type,
      feedback_type: feedback_types[:dismissal],
      project_fingerprint: bin_to_str_fingerprint(finding_dismissed.project_fingerprint))

    feedbacks.create!(
      id: 2, project_id: project.id, author_id: author.id, category: finding_non_dismissal_feedback.report_type,
      feedback_type: feedback_types[:issue], issue_id: issue.id,
      project_fingerprint: bin_to_str_fingerprint(finding_non_dismissal_feedback.project_fingerprint))
  end

  def find(id)
    vulnerabilities.find(id)
  end

  describe '#up' do
    it 'sets "resolved" state only for resolved vulnerabilities' do
      freeze_time do
        migrate!

        expect(find(vulnerability_open_id)).to have_attributes(state: states[:opened], resolved_by_id: nil, resolved_at: nil)
        expect(find(vulnerability_resolved_id)).to(
          have_attributes(state: states[:resolved], resolved_by_id: closer_id, resolved_at: be_like_time(Time.current)))
        expect(find(vulnerability_dismissed_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
        expect(find(vulnerability_orphan_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
        expect(find(vulnerability_non_dismissal_feedback_id)).to(
          have_attributes(state: states[:resolved], resolved_by_id: closer_id, resolved_at: be_like_time(Time.current)))
      end
    end
  end

  describe '#down' do
    it 'rolls back the migration correctly' do
      expect(find(vulnerability_open_id)).to have_attributes(state: states[:opened], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_resolved_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_dismissed_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_orphan_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_non_dismissal_feedback_id)).to(
        have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil))

      migrate!

      schema_migrate_down!

      expect(find(vulnerability_open_id)).to have_attributes(state: states[:opened], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_resolved_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_dismissed_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_orphan_id)).to have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil)
      expect(find(vulnerability_non_dismissal_feedback_id)).to(
        have_attributes(state: states[:closed], resolved_by_id: nil, resolved_at: nil))
    end
  end
end

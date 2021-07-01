# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::UpdateVulnerabilitiesToDismissed, :migration, schema: 20200416111111 do
  let(:users) { table(:users) }
  let(:projects) { table(:projects) }
  let(:vulnerabilities) { table(:vulnerabilities) }
  let(:pipelines) { table(:ci_pipelines) }
  let(:vulnerability_occurrences) { table(:vulnerability_occurrences) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:feedback) { table(:vulnerability_feedback) }

  let(:severity) { ::Enums::Vulnerability.severity_levels[:unknown] }
  let(:confidence) { ::Enums::Vulnerability.confidence_levels[:medium] }
  let(:report_type) { ::Enums::Vulnerability.report_types[:sast] }

  let!(:user) { users.create!(id: 13, email: 'author@example.com', username: 'author', projects_limit: 10) }
  let!(:project) { projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab') }

  let(:scanner) do
    scanners.create!(id: 6, project_id: project.id, external_id: 'trivy', name: 'Security Scanner')
  end

  let(:identifier) do
    identifiers.create!(id: 7,
      project_id: 123,
      fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c7',
      external_type: 'SECURITY_ID',
      external_id: 'SECURITY_0',
      name: 'SECURITY_IDENTIFIER 0')
  end

  context 'vulnerability_occurrence has an associated vulnerability' do
    let!(:vulnerability) { vulnerabilities.create!(vuln_params) }
    let!(:pipeline) { pipelines.create!(id: 234, project_id: project.id, ref: project.default_branch, sha: 'adf43c3a', status: :success, user_id: user.id) }

    let!(:vulnerability_occurrence) do
      vulnerability_occurrences.create!(
        id: 1, report_type: vulnerability.report_type, name: 'finding_1',
        primary_identifier_id: identifier.id, uuid: 'abc', project_fingerprint: 'abc123',
        location_fingerprint: 'abc456', project_id: project.id, scanner_id: scanner.id, severity: severity,
        confidence: confidence, metadata_version: 'sast:1.0', raw_metadata: '{}', vulnerability_id: vulnerability.id)
    end

    context 'has been dismissed' do
      let!(:dismiss_feedback) do
        feedback.create!(category: vulnerability_occurrence.report_type, feedback_type: 0,
               project_id: project.id, project_fingerprint: vulnerability_occurrence.project_fingerprint.unpack1('H*'),
               author_id: user.id)
      end

      it 'vulnerability should now have state of dismissed' do
        expect(vulnerability.state)
          .to eq(described_class::VULNERABILITY_DETECTED)

        expect { described_class.new.perform(project.id) }
          .to change { vulnerability.reload.state }
          .from(described_class::VULNERABILITY_DETECTED)
          .to(described_class::VULNERABILITY_DISMISSED)
      end

      context 'project is archived' do
        let!(:project) { projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab', archived: true) }

        it 'vulnerability should remain in detected state' do
          expect(vulnerability.state).to eq(described_class::VULNERABILITY_DETECTED)

          expect { described_class.new.perform(project.id) }.not_to change { vulnerability.reload.state }.from(described_class::VULNERABILITY_DETECTED)
        end
      end

      context 'project is set to be deleted' do
        let!(:project) { projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab', pending_delete: true) }

        it 'vulnerability should remain in detected state' do
          expect(vulnerability.state).to eq(described_class::VULNERABILITY_DETECTED)

          expect { described_class.new.perform(project.id) }.not_to change { vulnerability.reload.state }.from(described_class::VULNERABILITY_DETECTED)
        end
      end
    end

    context 'has not been dismissed' do
      it 'vulnerability should remain in detected state' do
        expect(vulnerability.state)
          .to eq(described_class::VULNERABILITY_DETECTED)

        expect { described_class.new.perform(project.id) }.not_to change { vulnerability.reload.state }
          .from(described_class::VULNERABILITY_DETECTED)
      end
    end
  end

  def vuln_params
    {
      title: 'title',
      state: described_class::VULNERABILITY_DETECTED,
      severity: severity,
      confidence: confidence,
      report_type: report_type,
      project_id: project.id,
      author_id: user.id
    }
  end
end

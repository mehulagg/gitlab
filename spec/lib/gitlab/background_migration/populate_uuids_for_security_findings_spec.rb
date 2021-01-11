# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:ci_pipelines) { table(:ci_pipelines) }
  let(:ci_builds) { table(:ci_builds) }
  let(:ci_artifacts) { table(:ci_job_artifacts) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:security_scans) { table(:security_scans) }
  let(:security_findings) { table(:security_findings) }

  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: namespace.id, name: 'foo') }
  let(:ci_pipeline) { ci_pipelines.create!(project_id: project.id, ref: 'master', sha: 'adf43c3a', status: 'success') }
  let(:ci_build_1) { ci_builds.create!(commit_id: ci_pipeline.id, retried: false, type: 'Ci::Build') }
  let(:ci_build_2) { ci_builds.create!(commit_id: ci_pipeline.id, retried: false, type: 'Ci::Build') }
  let(:ci_build_3) { ci_builds.create!(commit_id: ci_pipeline.id, retried: false, type: 'Ci::Build') }
  let(:ci_artifact_1) { ci_artifacts.create!(project_id: project.id, job_id: ci_build_1.id, file_type: 5, file_format: 1) }
  let(:ci_artifact_2) { ci_artifacts.create!(project_id: project.id, job_id: ci_build_2.id, file_type: 8, file_format: 1) }
  let(:ci_artifact_3) { ci_artifacts.create!(project_id: project.id, job_id: ci_build_3.id, file_type: 8, file_format: 1, expire_at: -1.days.from_now) }
  let(:scanner) { scanners.create!(project_id: project.id, external_id: 'bandit', name: 'Bandit') }
  let(:security_scan_1) { security_scans.create!(build_id: ci_build_1.id, scan_type: 1) }
  let(:security_scan_2) { security_scans.create!(build_id: ci_build_2.id, scan_type: 4) }
  let(:security_scan_3) { security_scans.create!(build_id: ci_build_3.id, scan_type: 4) }
  let(:sast_file) { fixture_file_upload(Rails.root.join('ee/spec/fixtures/security_reports/master/gl-sast-report.json'), 'application/json') }
  let(:dast_file) { fixture_file_upload(Rails.root.join('ee/spec/fixtures/security_reports/master/gl-dast-report.json'), 'application/json') }

  let!(:finding_1) { security_findings.create!(scan_id: security_scan_1.id, scanner_id: scanner.id, severity: 0, confidence: 0, position: 0, project_fingerprint: SecureRandom.uuid) }
  let!(:finding_2) { security_findings.create!(scan_id: security_scan_2.id, scanner_id: scanner.id, severity: 0, confidence: 0, position: 0, project_fingerprint: SecureRandom.uuid) }
  let!(:finding_3) { security_findings.create!(scan_id: security_scan_3.id, scanner_id: scanner.id, severity: 0, confidence: 0, position: 0, project_fingerprint: SecureRandom.uuid) }

  before do
    described_class::Artifact.find(ci_artifact_1.id).update!(file: sast_file)
    described_class::Artifact.find(ci_artifact_2.id).update!(file: dast_file)
    described_class::Artifact.find(ci_artifact_3.id).update!(file: dast_file)
  end

  describe '#perform' do
    subject(:populate_uuids) { described_class.new.perform([security_scan_1.id, security_scan_2.id, security_scan_3.id]) }

    it 'sets the `uuid` of findings' do
      expect { populate_uuids }.to change { finding_1.reload.uuid }.from(nil)
                               .and change { finding_2.reload.uuid }.from(nil)
    end

    it 'removes the uncoverable findings' do
      expect { populate_uuids }.to change { described_class::SecurityFinding.find_by(id: finding_3.id) }.to(nil)
    end
  end
end

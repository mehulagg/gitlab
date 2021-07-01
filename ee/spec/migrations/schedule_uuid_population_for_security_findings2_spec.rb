# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleUuidPopulationForSecurityFindings2 do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:ci_pipelines) { table(:ci_pipelines) }
  let(:ci_builds) { table(:ci_builds) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:security_scans) { table(:security_scans) }
  let(:security_findings) { table(:security_findings) }

  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: namespace.id, name: 'foo') }
  let(:ci_pipeline) { ci_pipelines.create!(project_id: project.id, ref: project.default_branch, sha: 'adf43c3a', status: 'success') }
  let(:ci_build) { ci_builds.create!(commit_id: ci_pipeline.id, retried: false, type: 'Ci::Build') }
  let(:scanner) { scanners.create!(project_id: project.id, external_id: 'bandit', name: 'Bandit') }
  let(:security_scan_1) { security_scans.create!(build_id: ci_build.id, scan_type: 0) }
  let(:security_scan_2) { security_scans.create!(build_id: ci_build.id, scan_type: 1) }

  around do |example|
    freeze_time { Sidekiq::Testing.fake! { example.run } }
  end

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)

    3.times do
      security_findings.create!(scan_id: security_scan_1.id, scanner_id: scanner.id, severity: 0, confidence: 0, project_fingerprint: SecureRandom.uuid)
    end

    security_findings.create!(scan_id: security_scan_2.id, scanner_id: scanner.id, severity: 0, confidence: 0, project_fingerprint: SecureRandom.uuid)
  end

  it 'schedules the background jobs', :aggregate_failures do
    migrate!

    expect(BackgroundMigrationWorker.jobs.size).to be(2)
    expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(2.minutes, security_scan_1.id)
    expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(4.minutes, security_scan_2.id)
  end
end

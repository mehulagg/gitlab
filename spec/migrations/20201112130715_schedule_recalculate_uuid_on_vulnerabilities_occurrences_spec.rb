# frozen_string_literal: true

require 'spec_helper'
require_migration!('schedule_recalculate_uuid_on_vulnerabilities_occurrences')

RSpec.describe ScheduleRecalculateUuidOnVulnerabilitiesOccurrences, :migration do
  let(:namespace) { table(:namespaces).create!(name: 'user', path: 'user') }
  let(:users) { table(:users) }
  let(:user) { create_user! }
  let(:project) { table(:projects).create!(id: 123, namespace_id: namespace.id) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:scanner) { scanners.create!(project_id: project.id, external_id: 'test 1', name: 'test scanner 1') }
  let(:different_scanner) { scanners.create!(project_id: project.id, external_id: 'test 2', name: 'test scanner 2') }
  let(:vulnerabilities) { table(:vulnerabilities) }
  let(:vulnerabilities_findings) { table(:vulnerability_occurrences) }
  let(:vulnerability_identifiers) { table(:vulnerability_identifiers) }
  let(:vulnerability_identifier) do
    vulnerability_identifiers.create!(
      project_id: project.id,
      external_type: 'uuid-v5',
      external_id: 'uuid-v5',
      fingerprint: '7e394d1b1eb461a7406d7b1e08f057a1cf11287a',
      name: 'Identifier for UUIDv5')
  end

  let(:different_vulnerability_identifier) do
    vulnerability_identifiers.create!(
      project_id: project.id,
      external_type: 'uuid-v4',
      external_id: 'uuid-v4',
      fingerprint: '772da93d34a1ba010bcb5efa9fb6f8e01bafcc89',
      name: 'Identifier for UUIDv4')
  end

  let!(:vulnerability_for_uuidv4) do
    create_vulnerability!(
      project_id: project.id,
      author_id: user.id
    )
  end

  let!(:vulnerability_for_uuidv5) do
    create_vulnerability!(
      project_id: project.id,
      author_id: user.id
    )
  end

  let(:known_uuid_v4) { "b3cc2518-5446-4dea-871c-89d5e999c1ac" }
  let!(:finding_with_uuid_v4) do
    create_finding!(
      vulnerability_id: vulnerability_for_uuidv4.id,
      project_id: project.id,
      scanner_id: different_scanner.id,
      primary_identifier_id: different_vulnerability_identifier.id,
      report_type: 0, # "sast"
      location_fingerprint: "fa18f432f1d56675f4098d318739c3cd5b14eb3e",
      uuid: known_uuid_v4
    )
  end

  let(:known_uuid_v5) { "e7d3d99d-04bb-5771-bb44-d80a9702d0a2" }
  let!(:finding_with_uuid_v5) do
    create_finding!(
      vulnerability_id: vulnerability_for_uuidv5.id,
      project_id: project.id,
      scanner_id: scanner.id,
      primary_identifier_id: vulnerability_identifier.id,
      report_type: 0, # "sast"
      location_fingerprint: "838574be0210968bf6b9f569df9c2576242cbf0a",
      uuid: known_uuid_v5
    )
  end

  before do
    stub_const("#{described_class}::BATCH_SIZE", 1)
  end

  around do |example|
    freeze_time { Sidekiq::Testing.fake! { example.run } }
  end

  it 'schedules background migration' do
    migrate!

    expect(BackgroundMigrationWorker.jobs.size).to eq(2)
    expect(described_class::MIGRATION).to be_scheduled_migration(finding_with_uuid_v4.id, finding_with_uuid_v4.id)
    expect(described_class::MIGRATION).to be_scheduled_migration(finding_with_uuid_v5.id, finding_with_uuid_v5.id)
  end

  private

  def create_vulnerability!(project_id:, author_id:, title: 'test', severity: 7, confidence: 7, report_type: 0)
    vulnerabilities.create!(
      project_id: project_id,
      author_id: author_id,
      title: title,
      severity: severity,
      confidence: confidence,
      report_type: report_type
    )
  end

  # rubocop:disable Metrics/ParameterLists
  def create_finding!(
    vulnerability_id:, project_id:, scanner_id:, primary_identifier_id:,
                      name: "test", severity: 7, confidence: 7, report_type: 0,
                      project_fingerprint: '123qweasdzxc', location_fingerprint: 'test',
                      metadata_version: 'test', raw_metadata: 'test', uuid: 'test')
    vulnerabilities_findings.create!(
      vulnerability_id: vulnerability_id,
      project_id: project_id,
      name: name,
      severity: severity,
      confidence: confidence,
      report_type: report_type,
      project_fingerprint: project_fingerprint,
      scanner_id: scanner.id,
      primary_identifier_id: vulnerability_identifier.id,
      location_fingerprint: location_fingerprint,
      metadata_version: metadata_version,
      raw_metadata: raw_metadata,
      uuid: uuid
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def create_user!(name: "Example User", email: "user@example.com", user_type: nil, created_at: Time.now, confirmed_at: Time.now)
    users.create!(
      name: name,
      email: email,
      username: name,
      projects_limit: 0,
      user_type: user_type,
      confirmed_at: confirmed_at
    )
  end
end

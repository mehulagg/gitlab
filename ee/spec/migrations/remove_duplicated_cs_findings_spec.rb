# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'post_migrate', '20200910131218_remove_duplicated_cs_findings.rb')

RSpec.describe RemoveDuplicatedCsFindings, :migration do
  include MigrationHelpers::VulnerabilitiesFindingsHelper

  let(:migration) { 'RemoveDuplicateCsFindings'}
  let(:namespaces) { table(:namespaces) }
  let(:notes) { table(:notes) }
  let(:group) { namespaces.create!(name: 'foo', path: 'foo') }
  let(:projects) { table(:projects) }
  let(:findings) { table(:vulnerability_occurrences) }
  let(:scanners) { table(:vulnerability_scanners) }

  let(:identifiers) { table(:vulnerability_identifiers) }
  let!(:project) { projects.create!(id: 12058473, namespace_id: group.id, name: 'gitlab', path: 'gitlab') }
  let!(:scanner) do
    scanners.create!(id: 6, project_id: project.id, external_id: 'trivy', name: 'Security Scanner')
  end

  before do
    stub_const("#{described_class}::BATCH_SIZE", 2)
  end

  around do |example|
    freeze_time { Sidekiq::Testing.fake! { example.run } }
  end

  it 'updates location fingerprint for containter scanning findings', :sidekiq_might_not_need_inline do
    allow(::Gitlab).to receive(:com?).and_return(true)

    ids = [231411, 231412, 231413, 231500, 231600, 231700]

    fingerprints = %w(
      6c871440eb9f7618b9aef25e5246acddff6ed7a1
      9d1a47927875f1aee1e2b9f16c25a8ff7586f1a6
      d7da2cc109c18d890ab239e833524d451cc45246
      6c871440eb9f7618b9aef25e5246acddff6ed7a1
      9d1a47927875f1aee1e2b9f16c25a8ff7586f1a6
      d7da2cc109c18d890ab239e833524d451cc45246
    )

    7.times.each { |x| identifiers.create!(vulnerability_identifer_params(x, project.id)) }
    3.times.each { |x| findings.create!(finding_params(x, project.id).merge({ id: ids[x], location_fingerprint: fingerprints[x] })) }
    findings.create!(finding_params(0, project.id).merge({ id: ids[3], location_fingerprint: Gitlab::Database::ShaAttribute.new.serialize(fingerprints[3]).to_s }))
    findings.create!(finding_params(1, project.id).merge({ id: ids[4], location_fingerprint: Gitlab::Database::ShaAttribute.new.serialize(fingerprints[4]).to_s }))
    findings.create!(finding_params(2, project.id).merge({ id: ids[5], location_fingerprint: Gitlab::Database::ShaAttribute.new.serialize(fingerprints[5]).to_s }))

    migrate!

    expect(migration)
      .to be_scheduled_delayed_migration(2.minutes, 231411, 231412)

    expect(migration)
      .to be_scheduled_delayed_migration(4.minutes, 231413, 231413)

    expect(BackgroundMigrationWorker.jobs.size).to eq(2)
  end

  it 'skips migration for on premise' do
    allow(::Gitlab).to receive(:com?).and_return(true)

    migrate!

    expect(BackgroundMigrationWorker.jobs.size).to eq(0)
  end

  def vulnerability_identifer_params(id, project_id)
    {
      id: id,
      project_id: project_id,
      fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c' + id.to_s,
      external_type: 'SECURITY_ID',
      external_id: 'SECURITY_0',
      name: 'SECURITY_IDENTIFIER 0'
    }
  end

  def vulnerability_params(project_id, user_id)
    {
      title: 'title',
      state: 1,
      confidence: 5,
      severity: 6,
      report_type: 2,
      project_id: project.id,
      author_id: user.id
    }
  end

  def finding_params(primary_identifier_id, project_id)
    attrs = attributes_for_vulnerabilities_finding
    custom_attrs = {
      severity: 0,
      confidence: 5,
      report_type: 2,
      project_id: project_id,
      scanner_id: 6,
      primary_identifier_id: primary_identifier_id
    }
    attrs.merge(custom_attrs)
  end

  def create_identifier(number_of)
    (1..number_of).each do |identifier_id|
      identifiers.create!(id: identifier_id,
                          project_id: 123,
                          fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c' + identifier_id.to_s,
                          external_type: 'SECURITY_ID',
                          external_id: 'SECURITY_0',
                          name: 'SECURITY_IDENTIFIER 0')
    end
  end
end

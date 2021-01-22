# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'post_migrate', '20200908095446_update_location_fingerprint_column_for_cs.rb')

RSpec.describe UpdateLocationFingerprintColumnForCs, :migration do
  let(:namespaces) { table(:namespaces) }
  let(:users) { table(:users) }
  let(:group) { namespaces.create!(name: 'foo', path: 'foo') }
  let(:projects) { table(:projects) }
  let(:findings) { table(:vulnerability_occurrences) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let!(:project) { projects.create!(id: 123, namespace_id: group.id, name: 'gitlab', path: 'gitlab') }

  let!(:scanner) do
    scanners.create!(id: 6, project_id: project.id, external_id: 'clair', name: 'Security Scanner')
  end

  let!(:user) do
    users.create!(id: 13, email: 'author@example.com', notification_email: 'author@example.com', name: 'author', username: 'author', projects_limit: 10, state: 'active')
  end

  before do
    stub_const("#{described_class}::BATCH_SIZE", 2)
  end

  it 'updates location fingerprint for containter scanning findings', :sidekiq_might_not_need_inline do
    raw_metadata = [
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"apparmor\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/alpine-ruby2/master:49dda736b6386592f7dd0367bcdd260cb84edfa8\"} }",
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"glibc\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/docker/master:2.1\"} }"
    ]

    new_fingerprints = %w(6c871440eb9f7618b9aef25e5246acddff6ed7a1 9d1a47927875f1aee1e2b9f16c25a8ff7586f1a6)

    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(true)

    create_identifier(2)

    findings.create!(finding_params(1).merge({ raw_metadata: raw_metadata[0] }))
    findings.create!(finding_params(2).merge({ raw_metadata: raw_metadata[1] }))

    migrate!

    location_fingerprints = findings.pluck(:location_fingerprint).flat_map { |x| Gitlab::Database::ShaAttribute.new.deserialize(x) }

    expect(location_fingerprints).to match_array(new_fingerprints)
  end

  it 'skips migration for ce' do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(false)

    create_identifier(2)

    findings.create!(finding_params(1))
    findings.create!(finding_params(2))

    before_location_fingerprints = findings.pluck(:location_fingerprint).flat_map { |x| Gitlab::Database::ShaAttribute.new.deserialize(x) }

    migrate!

    after_location_fingerprints = findings.pluck(:location_fingerprint).flat_map { |x| Gitlab::Database::ShaAttribute.new.deserialize(x) }

    expect(after_location_fingerprints).to match_array(before_location_fingerprints)
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

  def finding_params(primary_identifier_id)
    attrs = attributes_for(:vulnerabilities_finding) # rubocop: disable RSpec/FactoriesInMigrationSpecs
    {
      severity: 0,
      confidence: 5,
      report_type: 2,
      project_id: 123,
      scanner_id: 6,
      primary_identifier_id: primary_identifier_id,
      project_fingerprint: attrs[:project_fingerprint],
      location_fingerprint: Digest::SHA1.hexdigest(SecureRandom.hex(10)),
      uuid: attrs[:uuid],
      name: attrs[:name],
      metadata_version: '1.3',
      raw_metadata: attrs[:raw_metadata]
    }
  end
end

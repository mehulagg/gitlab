# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::UpdateLocationFingerprintForContainerScanningFindings, :migration, schema: 20200908095446 do
  let(:namespaces) { table(:namespaces) }
  let(:group) { namespaces.create!(name: 'foo', path: 'foo') }
  let(:projects) { table(:projects) }
  let(:findings) { table(:vulnerability_occurrences) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:identifiers) { table(:vulnerability_identifiers) }

  let!(:project) { projects.create!(id: 123, namespace_id: group.id, name: 'gitlab', path: 'gitlab') }

  let!(:scanner) do
    scanners.create!(id: 6, project_id: project.id, external_id: 'clair', name: 'Security Scanner')
  end

  it 'updates location fingerprint' do
    raw_metadata = [
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"apparmor\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/alpine-ruby2/master:49dda736b6386592f7dd0367bcdd260cb84edfa8\"} }",
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"glibc\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/docker/master:2.1\"} }",
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"apt\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/gitlab/master:49dda73\"} }"
    ]

    new_fingerprints = %w(6c871440eb9f7618b9aef25e5246acddff6ed7a1 9d1a47927875f1aee1e2b9f16c25a8ff7586f1a6 d7da2cc109c18d890ab239e833524d451cc45246)

    create_identifier(3)

    vul1 = findings.create!(finding_params(1).merge({ raw_metadata: raw_metadata[0] }))
    findings.create!(finding_params(2).merge({ raw_metadata: raw_metadata[1] }))
    vul3 = findings.create!(finding_params(3).merge({ raw_metadata: raw_metadata[2] }))

    expect(findings.where(report_type: 2).count). to eq(3)

    described_class.new.perform(vul1.id, vul3.id)

    location_fingerprints = findings.pluck(:location_fingerprint).flat_map { |x| Gitlab::Database::ShaAttribute.new.deserialize(x) }

    expect(location_fingerprints).to match_array(new_fingerprints)
  end

  it 'updates the rest when there is a collision' do
    allow(::Gitlab::BackgroundMigration::Logger).to receive(:warn).with(any_args).and_call_original

    raw_metadata = [
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"apparmor\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/alpine-ruby2/master:49dda736b6386592f7dd0367bcdd260cb84edfa8\"} }",
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"glibc\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/docker/master:2.1\"} }",
      "{ \"location\":{\"dependency\":{\"package\":{\"name\":\"apt\"},\"version\":\"2.10.95-0ubuntu2.11\"},\"operating_system\":\"ubuntu:16.04\",\"image\":\"registry.staging.gitlab.com/gitlab/gitlab/master:49dda73\"} }"
    ]

    new_fingerprints = %w(74657374 6c871440eb9f7618b9aef25e5246acddff6ed7a1 9d1a47927875f1aee1e2b9f16c25a8ff7586f1a6 d7da2cc109c18d890ab239e833524d451cc45246)

    create_identifier(3)

    # exsiting data in db
    vul1 = findings.create!(finding_params(1).merge({ raw_metadata: raw_metadata[0], location_fingerprint: '36633837313434306562396637363138623961656632356535323436616364646666366564376131' }))
    findings.create!(finding_params(1).merge({ raw_metadata: raw_metadata[0], location_fingerprint: 'test' }))
    findings.create!(finding_params(2).merge({ raw_metadata: raw_metadata[1] }))
    vul3 = findings.create!(finding_params(3).merge({ raw_metadata: raw_metadata[2] }))

    expect(findings.where(report_type: 2).count). to eq(4)

    described_class.new.perform(vul1.id, vul3.id)

    expect(::Gitlab::BackgroundMigration::Logger).to have_received(:warn).with(any_args)

    location_fingerprints = findings.pluck(:location_fingerprint).flat_map { |x| Gitlab::Database::ShaAttribute.new.deserialize(x) }

    expect(location_fingerprints).to match_array(new_fingerprints)
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

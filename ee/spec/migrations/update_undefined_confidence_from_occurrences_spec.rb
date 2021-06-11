# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe UpdateUndefinedConfidenceFromOccurrences, :migration do
  let(:vulnerabilities) { table(:vulnerability_occurrences) }
  let(:identifiers) { table(:vulnerability_identifiers) }
  let(:scanners) { table(:vulnerability_scanners) }
  let(:projects) { table(:projects) }
  let(:vul1) { attributes_for_vulnerability_finding(id: 1) }
  let(:vul2) { attributes_for_vulnerability_finding(id: 2) }

  before do
    stub_const("#{described_class}::BATCH_SIZE", 2)
  end

  it 'updates confidence levels for container scanning reports', :sidekiq_might_not_need_inline do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(true)

    projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab')

    identifiers.create!(id: 1,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c2',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    identifiers.create!(id: 2,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c3',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    scanners.create!(id: 6, project_id: 123, external_id: 'trivy', name: 'Security Scanner')

    vulnerabilities.create!(id: vul1[:id],
                            confidence: 0,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: vul1[:project_fingerprint],
                            location_fingerprint: vul1[:location_fingerprint],
                            uuid: vul1[:uuid],
                            name: vul1[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul1[:raw_metadata])

    vulnerabilities.create!(id: vul2[:id],
                            confidence: 2,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 2,
                            project_fingerprint: vul2[:project_fingerprint],
                            location_fingerprint: vul2[:location_fingerprint],
                            uuid: vul2[:uuid],
                            name: vul2[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul2[:raw_metadata])

    expect(vulnerabilities.where(confidence: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(confidence: 0)).to be_falsy
  end

  it 'skips migration for ce' do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(false)

    projects.create!(id: 123, namespace_id: 12, name: 'gitlab', path: 'gitlab')

    identifiers.create!(id: 1,
                        project_id: 123,
                        fingerprint: 'd432c2ad2953e8bd587a3a43b3ce309b5b0154c2',
                        external_type: 'SECURITY_ID',
                        external_id: 'SECURITY_0',
                        name: 'SECURITY_IDENTIFIER 0')

    scanners.create!(id: 6, project_id: 123, external_id: 'trivy', name: 'Security Scanner')

    vulnerabilities.create!(id: vul1[:id],
                            confidence: 0,
                            severity: 3,
                            report_type: 2,
                            project_id: 123,
                            scanner_id: 6,
                            primary_identifier_id: 1,
                            project_fingerprint: vul1[:project_fingerprint],
                            location_fingerprint: vul1[:location_fingerprint],
                            uuid: vul1[:uuid],
                            name: vul1[:name],
                            metadata_version: '1.3',
                            raw_metadata: vul1[:raw_metadata])

    expect(vulnerabilities.where(confidence: 0).count). to eq(1)

    migrate!

    expect(vulnerabilities.exists?(confidence: 0)).to be_truthy
  end

  private

  def attributes_for_vulnerability_finding(id:, report_type: 2, confidence: 5)
    uuid = SecureRandom.uuid
    {
      id: id,
      confidence: confidence,
      report_type: report_type,
      project_fingerprint: SecureRandom.hex(20),
      location_fingerprint: Digest::SHA1.hexdigest(SecureRandom.hex(10)),
      uuid: uuid,
      name: "Vulnerability Finding #{uuid}",
      raw_metadata: raw_metadata
    }
  end

  def raw_metadata
    { "description" => "The cipher does not provide data integrity update 1",
     "message" => "The cipher does not provide data integrity",
     "cve" => "818bf5dacb291e15d9e6dc3c5ac32178:CIPHER",
     "solution" => "GCM mode introduces an HMAC into the resulting encrypted data, providing integrity of the result.",
     "location" => { "file" => "maven/src/main/java/com/gitlab/security_products/tests/App.java", "start_line" => 29, "end_line" => 29, "class" => "com.gitlab.security_products.tests.App", "method" => "insecureCypher" },
     "links" => [{ "name" => "Cipher does not check for integrity first?", "url" => "https://crypto.stackexchange.com/questions/31428/pbewithmd5anddes-cipher-does-not-check-for-integrity-first" }],
     "assets" => [{ "type" => "postman", "name" => "Test Postman Collection", "url" => "http://localhost/test.collection" }],
     "evidence" =>
      { "summary" => "Credit card detected",
       "request" => { "headers" => [{ "name" => "Accept", "value" => "*/*" }], "method" => "GET", "url" => "http://goat:8080/WebGoat/logout", "body" => nil },
       "response" => { "headers" => [{ "name" => "Content-Length", "value" => "0" }], "reason_phrase" => "OK", "status_code" => 200, "body" => nil },
       "source" => { "id" => "assert:Response Body Analysis", "name" => "Response Body Analysis", "url" => "htpp://hostname/documentation" },
       "supporting_messages" =>
        [{ "name" => "Origional", "request" => { "headers" => [{ "name" => "Accept", "value" => "*/*" }], "method" => "GET", "url" => "http://goat:8080/WebGoat/logout", "body" => "" } },
         { "name" => "Recorded",
          "request" => { "headers" => [{ "name" => "Accept", "value" => "*/*" }], "method" => "GET", "url" => "http://goat:8080/WebGoat/logout", "body" => "" },
          "response" => { "headers" => [{ "name" => "Content-Length", "value" => "0" }], "reason_phrase" => "OK", "status_code" => 200, "body" => "" } }] } }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  sequence :vulnerability_finding_uuid do |n|
    SecureRandom.uuid
  end

  factory :vulnerabilities_finding_with_remediation, parent: :vulnerabilities_finding do
    transient do
      summary { nil }
    end

    after(:build) do |finding, evaluator|
      if evaluator.summary
        raw_metadata = Gitlab::Json.parse(finding.raw_metadata)
        raw_metadata.delete('solution')
        raw_metadata['remediations'] = [
          {
            summary: evaluator.summary,
            diff: Base64.encode64("This ain't a diff")
          }
        ]
        finding.raw_metadata = raw_metadata.to_json
      end
    end

    trait :yarn_remediation do
      after(:build) do |finding, evaluator|
        if evaluator.summary
          raw_metadata = Gitlab::Json.parse(finding.raw_metadata)
          raw_metadata['remediations'] = [
            {
              summary: evaluator.summary,
              diff: Base64.encode64(
                File.read(
                  File.join(
                    Rails.root.join('ee/spec/fixtures/security_reports/remediations'), "remediation.patch")
                ))
            }
          ]
          finding.raw_metadata = raw_metadata.to_json
        end
      end
    end
  end

  factory :vulnerabilities_finding, class: 'Vulnerabilities::Finding' do
    name { 'Cipher with no integrity' }
    project
    sequence(:uuid) { generate(:vulnerability_finding_uuid) }
    project_fingerprint { generate(:project_fingerprint) }
    primary_identifier factory: :vulnerabilities_identifier
    location_fingerprint { '4e5b6966dd100170b4b1ad599c7058cce91b57b4' }
    report_type { :sast }
    severity { :high }
    confidence { :medium }
    scanner factory: :vulnerabilities_scanner
    metadata_version { 'sast:1.0' }
    raw_metadata do
      {
        description: 'The cipher does not provide data integrity update 1',
        message: 'The cipher does not provide data integrity',
        cve: '818bf5dacb291e15d9e6dc3c5ac32178:CIPHER',
        solution: 'GCM mode introduces an HMAC into the resulting encrypted data, providing integrity of the result.',
        location: {
          file: 'maven/src/main/java/com/gitlab/security_products/tests/App.java',
          start_line: 29,
          end_line: 29,
          class: 'com.gitlab.security_products.tests.App',
          method: 'insecureCypher'
        },
        links: [
          {
            name: 'Cipher does not check for integrity first?',
            url: 'https://crypto.stackexchange.com/questions/31428/pbewithmd5anddes-cipher-does-not-check-for-integrity-first'
          }
        ],
        assets: [
          {
            type: "postman",
            name: "Test Postman Collection",
            url: "http://localhost/test.collection"
          }
        ],
        evidence: {
          summary: 'Credit card detected',
          request: {
            headers: [{ name: 'Accept', value: '*/*' }],
            method: 'GET',
            url: 'http://goat:8080/WebGoat/logout',
            body: nil
          },
          response: {
            headers: [{ name: 'Content-Length', value: '0' }],
            reason_phrase: 'OK',
            status_code: 200,
            body: nil
          },
          source: {
            id: 'assert:Response Body Analysis',
            name: 'Response Body Analysis',
            url: 'htpp://hostname/documentation'
          },
          supporting_messages: [
            {
              name: 'Origional',
              request: {
                headers: [{ name: 'Accept', value: '*/*' }],
                method: 'GET',
                url: 'http://goat:8080/WebGoat/logout',
                body: ''
              }
            },
            {
              name: 'Recorded',
              request: {
                headers: [{ name: 'Accept', value: '*/*' }],
                method: 'GET',
                url: 'http://goat:8080/WebGoat/logout',
                body: ''
              },
              response: {
                headers: [{ name: 'Content-Length', value: '0' }],
                reason_phrase: 'OK',
                status_code: 200,
                body: ''
              }
            }
          ]
        }
      }.to_json
    end

    trait :detected do
      after(:create) do |finding|
        create(:vulnerability, :detected, project: finding.project, findings: [finding])
      end
    end

    trait :confirmed do
      after(:create) do |finding|
        create(:vulnerability, :confirmed, project: finding.project, findings: [finding])
      end
    end

    trait :resolved do
      after(:create) do |finding|
        create(:vulnerability, :resolved, project: finding.project, findings: [finding])
      end
    end

    trait :dismissed do
      with_dismissal_feedback

      after(:create) do |finding|
        create(:vulnerability, :dismissed, project: finding.project, findings: [finding])
      end
    end

    trait :with_dismissal_feedback do
      after(:create) do |finding|
        create(:vulnerability_feedback,
               :dismissal,
               project: finding.project,
               project_fingerprint: finding.project_fingerprint)
      end
    end

    trait :with_issue_feedback do
      after(:create) do |finding|
        create(:vulnerability_feedback,
               :issue,
               project: finding.project,
               project_fingerprint: finding.project_fingerprint)
      end
    end

    trait :with_secret_detection do
      after(:build) do |finding|
        finding.severity = "critical"
        finding.confidence = "unknown"
        finding.report_type = "secret_detection"
        finding.name = "AWS API key"
        finding.metadata_version = "3.0"
        finding.raw_metadata =
          { category: "secret_detection",
            name: "AWS API key",
            message: "AWS API key",
            description: "Amazon Web Services API key detected; please remove and revoke it if this is a leak.",
            cve: "aws-key.py:fac8c3618ca3c0b55431402635743c0d6884016058f696be4a567c4183c66cfd:AWS",
            severity: "Critical",
            confidence: "Unknown",
            raw_source_code_extract: "AKIAIOSFODNN7EXAMPLE",
            scanner: { id: "gitleaks", name: "Gitleaks" },
            location: { file: "aws-key.py",
                        commit: { author: "Analyzer", sha: "d874aae969588eb718e1ed18aa0be73ea69b3539" },
                        start_line: 5, end_line: 5 },
            identifiers: [{ type: "gitleaks_rule_id", name: "Gitleaks rule ID AWS", value: "AWS" }] }.to_json
      end

      after(:create) do |finding|
        create(:vulnerability, :detected, project: finding.project, findings: [finding])
      end
    end

    trait :with_remediation do
      after(:build) do |finding|
        raw_metadata = Gitlab::Json.parse(finding.raw_metadata)
        raw_metadata.delete(:solution)
        raw_metadata[:remediations] = [
          {
            summary: 'Use GCM mode which includes HMAC in the resulting encrypted data, providing integrity of the result.',
            diff: Base64.encode64("This is a diff")
          }
        ]
        finding.raw_metadata = raw_metadata.to_json
      end
    end

    trait :with_pipeline do
      after(:create) do |finding|
        pipeline = create(:ci_pipeline, project: finding.project)

        finding.pipelines = [pipeline]
      end
    end

    trait :identifier do
      after(:build) do |finding|
        identifier = build(
          :vulnerabilities_identifier,
          fingerprint: SecureRandom.hex(20),
          project: finding.project
        )

        finding.identifiers = [identifier]
      end
    end

    ::Enums::Vulnerability.report_types.keys.each do |security_report_type|
      trait security_report_type do
        report_type { security_report_type }
      end
    end
  end
end

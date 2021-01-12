# frozen_string_literal: true

FactoryBot.define do
  factory :security_finding, class: 'Security::Finding' do
    scanner factory: :vulnerabilities_scanner
    scan factory: :security_scan

    severity { :critical }
    confidence { :high }
    uuid { SecureRandom.uuid }
    project_fingerprint { generate(:project_fingerprint) } # We cant remove this now as we have a `NOT NULL` constraint in DB
  end
end

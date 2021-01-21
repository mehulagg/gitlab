# frozen_string_literal: true

FactoryBot.define do
  factory :security_finding, class: 'Security::Finding' do
    scanner factory: :vulnerabilities_scanner
    scan factory: :security_scan

    severity { :critical }
    confidence { :high }
    project_fingerprint { generate(:project_fingerprint) }
    sequence :position
  end
end

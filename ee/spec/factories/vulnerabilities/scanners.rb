# frozen_string_literal: true

FactoryBot.define do
  sequence(:vulnerability_scanner_external_id) do |n|
    "find_sec_bugs_#{n}"
  end

  factory :vulnerabilities_scanner, class: 'Vulnerabilities::Scanner' do
    sequence(:external_id) { generate(:vulnerability_scanner_external_id) }
    name { 'Find Security Bugs' }
    vendor { 'Security Vendor' }
    project
  end
end

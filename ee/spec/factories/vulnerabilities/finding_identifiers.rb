# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_finding_identifier, class: 'Vulnerabilities::FindingIdentifier' do
    finding factory: :vulnerabilities_finding
    identifier factory: :vulnerabilities_identifier
  end
end

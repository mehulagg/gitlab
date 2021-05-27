# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilties_finding_evidence, class: 'Vulnerabilities::Finding::Evidence' do
    summary { 'Evidence summary' }
  end
end

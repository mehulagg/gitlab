# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilties_finding_evidence_header, class: 'Vulnerabilities::Finding::Evidence::Header' do
    name { 'HEADER-NAME' }
    value { 'header-value' }
  end
end

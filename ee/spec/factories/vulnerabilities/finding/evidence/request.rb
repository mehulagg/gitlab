# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilties_finding_evidence_request, class: 'Vulnerabilities::Finding::Evidence::Request' do
    url { 'https://www.example.com' }
    body { 'Request body' }
  end
end

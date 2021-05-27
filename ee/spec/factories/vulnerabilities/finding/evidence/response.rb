# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilties_finding_evidence_response, class: 'Vulnerabilities::Finding::Evidence::Response' do
    reason_phrase { 'Response reason' }
    body { 'Response body' }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_finding_pipeline, class: 'Vulnerabilities::FindingPipeline' do
    finding factory: :vulnerabilities_finding
    pipeline factory: :ci_pipeline
  end
end

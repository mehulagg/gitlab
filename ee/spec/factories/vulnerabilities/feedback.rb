# frozen_string_literal: true

require 'digest'

FactoryBot.define do
  sequence :project_fingerprint do |n|
    Digest::SHA1.hexdigest n.to_s
  end

  factory :vulnerability_feedback, class: 'Vulnerabilities::Feedback' do
    project
    author
    issue { nil }
    merge_request { nil }
    pipeline { association(:ci_pipeline, project: project) }
    feedback_type { 'dismissal' }
    category { 'sast' }
    project_fingerprint { generate(:project_fingerprint) }
    vulnerability_data { { category: 'sast' } }
    finding_uuid { Gitlab::UUID.v5(SecureRandom.hex) }

    trait :dismissal do
      feedback_type { 'dismissal' }
      dismissal_reason { 'acceptable_risk' }
    end

    trait :comment do
      comment { 'a dismissal comment' }
      comment_timestamp { Time.zone.now }
      comment_author { author }
    end

    trait :issue do
      feedback_type { 'issue' }
      issue { association(:issue, project: project) }
    end

    trait :merge_request do
      feedback_type { 'merge_request' }
      merge_request { association(:merge_request, source_project: project) }
    end

    trait :sast do
      category { 'sast' }
    end

    trait :dependency_scanning do
      category { 'dependency_scanning' }
    end

    trait :container_scanning do
      category { 'container_scanning' }
    end

    trait :cluster_image_scanning do
      category { 'cluster_image_scanning' }
    end

    trait :dast do
      category { 'dast' }
    end
  end
end

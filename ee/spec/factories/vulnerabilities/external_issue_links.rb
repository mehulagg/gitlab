# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_external_issue_link, class: 'Vulnerabilities::ExternalIssueLink' do
    author
    vulnerability
    external_issue_key { 'GV-100' }
    external_project_key { '10001' }
    external_type { :jira }

    trait :created do
      link_type { :created }
    end

    transient do
      project { nil }
    end

    after(:build) do |link, evaluator|
      if evaluator.project
        link.vulnerability = create(:vulnerability, project: evaluator.project)
      end
    end
  end
end

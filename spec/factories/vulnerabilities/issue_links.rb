# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_issue_link, class: 'Vulnerabilities::IssueLink' do
    vulnerability
    issue

    trait :created do
      link_type { :created }
    end

    trait :related do
      link_type { :related }
    end

    transient do
      project { nil }
    end

    after(:build) do |link, evaluator|
      if evaluator.project
        link.vulnerability = create(:vulnerability, project: evaluator.project)
        link.issue = create(:issue, project: evaluator.project)
      end
    end
  end
end

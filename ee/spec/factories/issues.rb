# frozen_string_literal: true

FactoryBot.modify do
  factory :issue do
    trait :published do
      after(:create) do |issue|
        issue.create_status_page_published_incident!
      end
    end
  end
end

FactoryBot.define do
  factory :quality_test_case, parent: :issue do
    issue_type { :test_case }
  end
end

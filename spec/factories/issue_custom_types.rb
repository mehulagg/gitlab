# frozen_string_literal: true

FactoryBot.define do
  factory :issue_custom_type, class: 'Issues::CustomType' do
    group

    name { generate(:issue_custom_type_name) }
    icon_name { 'issue' }
    issue_type { Issue.issue_types['issue'] }

    trait :bug do
      issue_type { Issue.issue_types['issue'] }
      name { 'Bug' }
      icon_name { 'bug' }
    end

    trait :feature do
      issue_type { Issue.issue_types['issue'] }
      name { 'Feature' }
      icon_name { 'feature' }
    end

    trait :incident do
      issue_type { Issue.issue_types['incident'] }
      icon_name { 'incident' }
    end

    trait :test_case do
      issue_type { Issue.issue_types['test_case'] }
      icon_name { 'test_case' }
    end
  end
end

# frozen_string_literal: true

FactoryBot.modify do
  factory :project_setting do
    trait :has_vulnerabilities do
      has_vulnerabilities { true }
    end
  end
end

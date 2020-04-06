# frozen_string_literal: true

FactoryBot.modify do
  factory :namespace do
    trait :with_build_minutes do
      namespace_statistics factory: :namespace_statistics, shared_runners_seconds: 400.minutes.to_i
    end

    trait :with_build_minutes_limit do
      shared_runners_minutes_limit { 500 }
    end

    trait :with_not_used_build_minutes_limit do
      namespace_statistics factory: :namespace_statistics, shared_runners_seconds: 300.minutes.to_i
      shared_runners_minutes_limit { 500 }
    end

    trait :with_used_build_minutes_limit do
      namespace_statistics factory: :namespace_statistics, shared_runners_seconds: 1000.minutes.to_i
      shared_runners_minutes_limit { 500 }
    end
  end
end

FactoryBot.define do
  factory :namespace_with_plan, parent: :namespace do
    transient do
      plan { :default_plan }
      trial_ends_on { nil }
    end

    after(:create) do |namespace, evaluator|
      if evaluator.plan
        create(:gitlab_subscription,
               namespace: namespace,
               hosted_plan: create(evaluator.plan),
               trial: evaluator.trial_ends_on.present?,
               trial_ends_on: evaluator.trial_ends_on)
      end
    end
  end
end

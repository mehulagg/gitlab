# frozen_string_literal: true

FactoryBot.define do
  factory :epic, traits: [:has_internal_id] do
    title { generate(:title) }
    namespace { association(:group) }
    author

    trait :use_fixed_dates do
      start_date { Date.new(2010, 1, 1) }
      start_date_fixed { Date.new(2010, 1, 1) }
      start_date_is_fixed { true }
      end_date { Date.new(2010, 1, 3) }
      due_date_fixed { Date.new(2010, 1, 3) }
      due_date_is_fixed { true }
    end

    trait :confidential do
      confidential { true }
    end

    trait :opened do
      state { :opened }
    end

    trait :closed do
      state { :closed }
      closed_at { Time.now }
    end

    factory :labeled_epic do
      transient do
        labels { [] }
      end

      after(:create) do |epic, evaluator|
        epic.update!(labels: evaluator.labels)
      end
    end
  end
end

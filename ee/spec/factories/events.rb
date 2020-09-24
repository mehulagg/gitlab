# frozen_string_literal: true

FactoryBot.modify do
  factory :event do
    trait :epic_create_event do
      group
      author(factory: :user)
      target(factory: :epic)
      action { :created }
      project { nil }
    end

    trait(:approved) { action { :approved } }
  end
end

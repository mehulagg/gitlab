# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_rotation, class: 'IncidentManagement::OncallRotation' do
    association :schedule, factory: :incident_management_oncall_schedule
    sequence(:name) { |n| "On-call Rotation ##{n}" }
    starts_at { Time.current.change(usec: 0) }
    ends_at { nil }
    length { 5 }
    length_unit { :days }

    trait :with_active_period do
      active_period_start { '08:00' }
      active_period_end { '17:00' }
    end

    trait :with_participants do
      transient do
        participants_count { 1 }
      end

      after(:create) do |rotation, evaluator|
        evaluator.participants_count.times do
          user = create(:user)
          rotation.project.add_reporter(user)
          create(:incident_management_oncall_participant, rotation: rotation, user: user)
        end
      end
    end

    trait :utc do
      association :schedule, :utc, factory: :incident_management_oncall_schedule
    end
  end
end

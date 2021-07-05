# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_schedule, class: 'IncidentManagement::OncallSchedule' do
    project
    sequence(:name) { |n| "On-call Schedule ##{n}" }
    description { 'On-call description' }
    timezone { 'Europe/Berlin' }

    trait :utc do
      timezone { 'Etc/UTC' }
    end

    trait :with_rotation do
      transient do
        rotation_count { 1 }
      end

      after(:create) do |schedule, evaluator|
        evaluator.rotation_count.times do
          schedule.rotations << create(:incident_management_oncall_rotation, :with_participants, schedule: schedule)
        end
      end
    end
  end
end

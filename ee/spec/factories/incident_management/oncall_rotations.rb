# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_rotation, class: 'IncidentManagement::OncallRotation' do
    association :schedule, factory: :incident_management_oncall_schedule
    sequence(:name) { |n| "On-call Rotation ##{n}" }
    starts_at { Time.current.floor }
    length { 5 }
    length_unit { :days }

    trait :with_interval do
      interval_start { '08:00' }
      interval_end { '17:00' }
    end

    trait :with_participant do
      after(:create) do |rotation|
        user = create(:user)
        rotation.project.add_reporter(user)
        create(:incident_management_oncall_participant, rotation: rotation, user: user)
      end
    end
  end
end

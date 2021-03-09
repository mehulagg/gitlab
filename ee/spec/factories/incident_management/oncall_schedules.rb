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
  end
end

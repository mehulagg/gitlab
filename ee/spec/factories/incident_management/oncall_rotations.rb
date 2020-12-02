# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_rotation, class: 'IncidentManagement::OncallRotation' do
    association :oncall_schedule, factory: :incident_management_oncall_schedule
    name { 'Default On-call Rotation' }
    starts_at { Time.current }
    rotation_length { 5 }
    rotation_length_unit { :days }
  end
end

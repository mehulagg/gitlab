# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_shift, class: 'IncidentManagement::OncallShift' do
    association :oncall_rotation, factory: :incident_management_oncall_rotation
    association :participant, factory: :user
    starts_at { 5.days.ago }
    ends_at { 2.days.from_now }
  end
end

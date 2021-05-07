# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_shift, class: 'IncidentManagement::OncallShift' do
    association :participant, :with_developer_access, factory: :incident_management_oncall_participant
    rotation { participant.rotation }
    starts_at { rotation.starts_at }
    ends_at { starts_at + rotation.shift_cycle_duration }

    trait :utc do
      association :participant, :utc, :with_developer_access, factory: :incident_management_oncall_participant
    end
  end
end

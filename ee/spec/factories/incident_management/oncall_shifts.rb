# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_shift, class: 'IncidentManagement::OncallShift' do
    association :participant, :with_developer_access, factory: :incident_management_oncall_participant
    rotation { participant.rotation }
    starts_at { 5.days.ago }
    ends_at { 2.days.from_now }
  end
end

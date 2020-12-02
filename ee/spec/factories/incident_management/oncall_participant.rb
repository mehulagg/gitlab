# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_participant, class: 'IncidentManagement::OncallParticipant' do
    association :oncall_rotation, factory: :incident_management_oncall_rotation
    association :participant, factory: :user
  end
end

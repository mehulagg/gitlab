# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_issuable_escalation, class: 'IncidentManagement::IssuableEscalation' do
    association :issue
    association :policy, factory: :incident_management_escalation_policy
  end
end

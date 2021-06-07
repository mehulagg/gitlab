# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_issuable_escalation_status, class: 'IncidentManagement::IssuableEscalationStatus' do
    association :issue
    triggered

    trait :triggered do
      status { IncidentManagement::IssuableEscalationStatus.statuses[:acknowledged] }
    end
  end
end

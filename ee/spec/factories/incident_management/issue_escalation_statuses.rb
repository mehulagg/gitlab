# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_issue_escalation_status, class: 'IncidentManagement::IssueEscalationStatus' do
    association :issue
    triggered

    trait :triggered do
      status { IncidentManagement::IssueEscalationStatus.statuses[:acknowledged] }
    end
  end
end

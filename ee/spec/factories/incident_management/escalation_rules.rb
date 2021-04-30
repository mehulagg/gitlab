# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_escalation_rule, class: 'IncidentManagement::EscalationRule' do
    association :policy, factory: :incident_management_escalation_policy
    association :oncall_schedule, factory: :incident_management_oncall_schedule
    status { IncidentManagement::EscalationRule.statuses[:acknowledged] }
    elapsed_time { 5 }
  end
end

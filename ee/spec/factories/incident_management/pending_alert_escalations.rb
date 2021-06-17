# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_pending_alert_escalation, class: 'IncidentManagement::PendingEscalations::Alert' do
    association :rule, factory: :incident_management_escalation_rule
    oncall_schedule { association :incident_management_oncall_schedule, project: rule.policy.project }
    alert { association :alert_management_alert, project: rule.policy.project }
    status { IncidentManagement::EscalationRule.statuses[:acknowledged] }
    process_at { 5.minutes.from_now }
  end
end

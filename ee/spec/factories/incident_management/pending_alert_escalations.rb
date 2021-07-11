# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_pending_alert_escalation, class: 'IncidentManagement::PendingEscalations::Alert' do
    transient do
      project { create(:project) } # rubocop:disable FactoryBot/InlineAssociation
      policy { create(:incident_management_escalation_policy, project: project) } # rubocop:disable FactoryBot/InlineAssociation
    end

    rule { association :incident_management_escalation_rule, policy: policy }
    oncall_schedule { association :incident_management_oncall_schedule, project: project }
    alert { association :alert_management_alert, project: project }
    status { IncidentManagement::EscalationRule.statuses[:acknowledged] }
    process_at { 5.minutes.from_now }
  end
end

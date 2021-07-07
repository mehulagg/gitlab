# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_escalation_rule, class: 'IncidentManagement::EscalationRule' do
    transient do
      project { create(:project) } # rubocop:disable FactoryBot/InlineAssociation
    end

    policy { association :incident_management_escalation_policy, project: project }
    oncall_schedule { association :incident_management_oncall_schedule, project: project }
    status { IncidentManagement::EscalationRule.statuses[:acknowledged] }
    elapsed_time_seconds { 5.minutes }

    trait :resolved do
      status { IncidentManagement::EscalationRule.statuses[:resolved] }
    end
  end
end

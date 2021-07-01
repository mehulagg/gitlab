# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_escalation_rule, class: 'IncidentManagement::EscalationRule' do
    association :policy, factory: :incident_management_escalation_policy
    oncall_schedule { association :incident_management_oncall_schedule, project: policy.project }
    status { IncidentManagement::EscalationRule.statuses[:acknowledged] }
    elapsed_time_seconds { 5.minutes }

    trait :with_user do
      oncall_schedule { nil }
      association :user
    end
  end
end

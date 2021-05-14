# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_escalation_policy, class: 'IncidentManagement::EscalationPolicy' do
    association :project
    sequence :name do |n|
      "EscalationPolicy #{n}"
    end

    description { 'Policy description' }

    transient do
      rule_count { 1 }
    end

    after(:build) do |policy, evaluator|
      evaluator.rule_count.times do
        policy.rules << build(:incident_management_escalation_rule, policy: policy)
      end
    end
  end
end

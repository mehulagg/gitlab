# frozen_string_literal: true

FactoryBot.define do
  factory :security_orchestration_policy_configuration, class: 'Security::OrchestrationPolicyConfiguration' do
    project
    security_policy_management_project { association(:project) }
  end
end

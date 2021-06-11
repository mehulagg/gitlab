# frozen_string_literal: true

FactoryBot.define do
  factory :compliance_framework_project_setting, class: 'ComplianceManagement::ComplianceFramework::ProjectSettings' do
    project
    compliance_management_framework factory: :compliance_framework

    trait :sox do
      association :compliance_management_framework, :sox, factory: :compliance_framework
    end
  end
end

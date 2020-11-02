# frozen_string_literal: true

FactoryBot.define do
  factory :compliance_framework_project_setting, class: 'ComplianceManagement::ComplianceFramework::ProjectSettings' do
    project

    gdpr

    ComplianceManagement::Framework::DEFAULT_FRAMEWORKS.each do |framework|
      trait framework.identifier do
        compliance_management_framework { association :compliance_framework, framework.to_framework_params.merge(namespace: project.root_namespace) }
      end
    end
  end
end

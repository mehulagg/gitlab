# frozen_string_literal: true

FactoryBot.define do
  factory :compliance_framework_project_setting, class: 'ComplianceManagement::ComplianceFramework::ProjectSettings' do
    project
    framework { ComplianceManagement::ComplianceFramework::ProjectSettings.frameworks.keys.sample }

    ComplianceManagement::ComplianceFramework::ProjectSettings.frameworks.keys.each do |k|
      trait k do
        framework { k }
      end
    end
  end
end

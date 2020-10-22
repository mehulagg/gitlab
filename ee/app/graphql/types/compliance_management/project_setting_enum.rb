# frozen_string_literal: true

module Types
  module ComplianceManagement
    class ProjectSettingEnum < Types::BaseEnum
      description 'Names of compliance frameworks that can be assigned to a Project'

      ::ComplianceManagement::ComplianceFramework::ProjectSettings.frameworks.keys.each do |k|
        value(k)
      end
    end
  end
end

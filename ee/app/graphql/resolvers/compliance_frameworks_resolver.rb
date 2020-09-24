# frozen_string_literal: true

module Resolvers
  class ComplianceFrameworksResolver < BaseResolver
    type Types::ComplianceManagement::ComplianceFrameworkType, null: true

    alias_method :project, :object

    def resolve(**args)
      return ComplianceManagement::Framework.none unless project.compliance_framework_setting

      Array.wrap(project.compliance_framework_setting.framework)
    end
  end
end

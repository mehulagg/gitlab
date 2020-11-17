# frozen_string_literal: true

module Resolvers
  class ComplianceFrameworksResolver < BaseResolver
    type Types::ComplianceManagement::ComplianceFrameworkType, null: true

    alias_method :project, :object

    def resolve(**args)
      Array.wrap(project.compliance_framework_setting)
    end
  end
end

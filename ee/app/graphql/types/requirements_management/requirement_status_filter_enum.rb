# frozen_string_literal: true

module Types
  module RequirementsManagement
    class RequirementStatusFilterEnum < TestReportStateEnum
      graphql_name 'RequirementStatusFilter'
      description 'Status of a requirement based on last test report'

      value 'MISSING', value: 'missing', description: 'Requirements without any test report.'
    end
  end
end

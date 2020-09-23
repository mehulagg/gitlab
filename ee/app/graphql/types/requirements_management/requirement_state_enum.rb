# frozen_string_literal: true

module Types
  module RequirementsManagement
    class RequirementStateEnum < BaseEnum
      graphql_name 'RequirementState'
      description 'State of a requirement'

      value 'OPENED', value: 'opened'
      value 'ARCHIVED', value: 'archived'
    end
  end
end

# frozen_string_literal: true
# rubocop: disable Graphql/AuthorizeTypes because ComplianceFrameworkType is, and should only be, accessible via ProjectType

module Types
  module ComplianceManagement
    class ComplianceFrameworkType < Types::BaseObject
      graphql_name 'ComplianceFramework'
      description 'Represents a ComplianceFramework associated with a Project'

      field :name, GraphQL::STRING_TYPE,
            null: false,
            description: 'Name of the compliance framework'

      def name
        object.compliance_management_framework.name
      end
    end
  end
end

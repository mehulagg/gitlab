# frozen_string_literal: true
# rubocop: disable Graphql/AuthorizeTypes because ComplianceFrameworkType is, and should only be, accessible via ProjectType

module Types
  module ComplianceManagement
    class ComplianceFrameworkType < Types::BaseObject
      graphql_name 'ComplianceFramework'
      description 'Represents a ComplianceFramework associated with a Project'

      field :id, GraphQL::ID_TYPE,
            null: false,
            description: 'Compliance framework ID'

      field :name, GraphQL::STRING_TYPE,
            null: false,
            description: 'Name of the compliance framework'

      field :description, GraphQL::STRING_TYPE,
            null: false,
            description: 'Description of the compliance framework'

      field :color, GraphQL::STRING_TYPE,
            null: false,
            description: 'Hexadecimal representation of compliance framework\'s label color'
    end
  end
end

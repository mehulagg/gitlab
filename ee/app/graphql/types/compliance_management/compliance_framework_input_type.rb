# frozen_string_literal: true

module Types
  module ComplianceManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class ComplianceFrameworkInputType < BaseInputObject
      graphql_name 'ComplianceFrameworkInput'

      argument :name,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'New name for the compliance framework.'

      argument :description,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'New description for the compliance framework.'

      argument :color,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'New color representation of the compliance framework in hex format. e.g. #FCA121.'
    end
  end
end

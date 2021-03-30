# frozen_string_literal: true

module Types
  module IssuableType
    include Types::BaseInterface
    graphql_name 'Issuable'

    field :id,
          GraphQL::ID_TYPE,
          null: true,
          description: 'ID of the issuable.'

    field :title, GraphQL::STRING_TYPE,
          null: true,
          description: 'Title of the issue.'

    field :description, GraphQL::STRING_TYPE,
          null: true,
          description: 'Description of the issue.'

    field :reference, GraphQL::STRING_TYPE,
          null: false,
          description: 'Internal reference of the issuable. Returned in shortened format by default.',
          method: :to_reference do
      argument :full, GraphQL::BOOLEAN_TYPE, required: false, default_value: false,
               description: 'Boolean option specifying whether the reference should be returned in full.'
    end

    definition_methods do
      def resolve_type(object, context)
        case object
        when ::Issue
          Types::IssueType
        when ::MergeRequest
          Types::MergeRequestType
        end
      end
    end
  end
end

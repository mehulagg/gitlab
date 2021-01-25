# frozen_string_literal: true

module Types
  # rubocop:disable Graphql/AuthorizeTypes
  class MetadataType < ::Types::BaseObject
    graphql_name 'Metadata'

    field :version, GraphQL::STRING_TYPE, null: false,
          authorize: :read_instance_metadata,
          complexity: 0,
          description: 'Version'

    field :revision, GraphQL::STRING_TYPE, null: false,
          authorize: :read_instance_metadata,
          complexity: 0,
          description: 'Revision'

    field :query_complexity, GraphQL::INT_TYPE, null: false,
          complexity: 0,
          description: 'Query complexity score'

    def query_complexity
      RequestStore.store[:query_complexity]
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end

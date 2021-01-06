# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ExternalIssueType < BaseObject
    graphql_name 'ExternalIssue'
    description 'Represents an external issue'

    field :title, GraphQL::STRING_TYPE, null: true,
          description: 'Title of the issue in the external tracker'

    field :relative_reference, GraphQL::STRING_TYPE, null: true,
          description: 'Relative reference of the issue in the external tracker'

    field :status, GraphQL::STRING_TYPE, null: true,
          description: 'Status of the issue in the external tracker'

    field :external_tracker, GraphQL::STRING_TYPE, null: true,
          description: 'Type of external tracker'

    field :web_url, GraphQL::STRING_TYPE, null: true,
          description: 'URL to the issue in the external tracker'

    field :created_at, Types::TimeType, null: true,
          description: 'Timestamp of when the issue was created'

    field :updated_at, Types::TimeType, null: true,
          description: 'Timestamp of when the issue was updated'

    def relative_reference
      object.dig(:references, :relative)
    end
  end
  # rubocop: enable Graphql/AuthorizeTypes
end

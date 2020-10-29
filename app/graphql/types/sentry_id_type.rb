# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class SentryIDType < ::GraphQL::Types::ID
    graphql_name 'SentryID'
    description 'The identifier of an issue in Sentry'

    ::Gitlab::Graphql::Extensions::ScalarExtensions.id_subtypes << self
  end
  # rubocop: enable Graphql/AuthorizeTypes
end

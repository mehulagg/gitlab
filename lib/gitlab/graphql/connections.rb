# frozen_string_literal: true

module Gitlab
  module Graphql
    module Connections
      extend ActiveSupport::Concern

      prepended do
        def self.supports_keyset_pagination(supported = true)
          @supports_keyset_pagination = supported
        end

        def self.supports_keyset_pagination?
          @supports_keyset_pagination
        end
      end

      def self.use(_schema)
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          ActiveRecord::Relation,
          Gitlab::Graphql::Connections::Keyset::Connection
        )
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          Gitlab::Graphql::FilterableArray,
          Gitlab::Graphql::Connections::FilterableArrayConnection
        )
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          Gitlab::Graphql::ExternallyPaginatedArray,
          Gitlab::Graphql::Connections::ExternallyPaginatedArrayConnection
        )
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          Gitlab::Graphql::Pagination::Relations::OffsetActiveRecordRelation,
          Gitlab::Graphql::Pagination::OffsetActiveRecordRelationConnection
        )
      end
    end
  end
end

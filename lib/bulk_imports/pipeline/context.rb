# frozen_string_literal: true

module BulkImports
  module Pipeline
    class Context < SimpleDelegator
      def http_client
        @http_client ||= BulkImports::Clients::Http.new(
          uri: @configuration.url,
          token: @configuration.access_token,
          per_page: 100
        )
      end

      def graphql_client
        @graphql_client ||= BulkImports::Clients::Graphql.new(
          url: @context.configuration.url,
          token: @context.configuration.access_token
        )
      end

      def current_user
        bulk_import.user
      end
    end
  end
end

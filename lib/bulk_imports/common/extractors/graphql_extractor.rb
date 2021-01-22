# frozen_string_literal: true

module BulkImports
  module Common
    module Extractors
      class GraphqlExtractor
        def initialize(options = {})
          @query = options[:query]
          @key_path = options[:key_path]
        end

        def extract(context)
          client = graphql_client(context)

          response = client.execute(
            client.parse(query.to_s),
            query.variables(context.entity)
          ).original_hash.deep_dup

          ExtractedData.new(
            data: response.dig(@key_path),
            next_page: response.dig('page_info')
          )
        end

        private

        attr_reader :query

        def graphql_client(context)
          @graphql_client ||= BulkImports::Clients::Graphql.new(
            url: context.configuration.url,
            token: context.configuration.access_token
          )
        end

        def parsed_query
          @parsed_query ||= graphql_client.parse(query.to_s)
        end
      end
    end
  end
end

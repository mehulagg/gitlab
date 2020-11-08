# frozen_string_literal: true

module BulkImports
  module Common
    module Extractors
      class GraphqlExtractor
        def initialize(query)
          @query = query
        end

        def extract(context)
          Enumerator.new do |yielder|
            yielder << context
              .graphql_client
              .execute(parsed_query, query.variables(context))
              .original_hash
              .deep_dup
              .with_indifferent_access
          end
        end

        private

        attr_reader :query

        def parsed_query
          @parsed_query ||= graphql_client.parse(query.to_s)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Common
      module Extractors
        class GraphqlExtractor
          def self.extract(context)
            self.new(context).extract
          end

          def initialize(context)
            @context = context
          end

          attr_reader :context

          def extract
            query = graphql_client.parse(context.query)

            Enumerator.new do |yielder|
              context.import_entities.each do |entity|
                variables = query_variables(context.variables, entity)
                result = graphql_client.execute(query, variables)

                yielder << result.original_hash.deep_dup
              end
            end
          end

          def graphql_client
            @graphql_client ||= Gitlab::BulkImport::Graphql::Client.new(url: context.import_config.url, token: context.import_config.token)
          end

          def query_variables(variables, entity)
            query_variables = {}

            variables.each { |v| query_variables[v] = entity.public_send(v) } # rubocop:disable GitlabSecurity/PublicSend

            query_variables
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Gitlab
  module EtagCaching
    module Router
      class Graphql
        GRAPHQL_ETAG_RESOURCE_HEADER = 'X-GITLAB-GRAPHQL-RESOURCE-ETAG'

        ROUTES = [
          Gitlab::EtagCaching::Router::Route.new(
            %r(\Apipelines/id/\d+\z),
            'pipelines_graph',
            'continuous_integration'
          )
        ].freeze

        def self.match(request)
          return unless '/api/graphql' == request.path_info

          graphql_resource = request.headers[GRAPHQL_ETAG_RESOURCE_HEADER]
          return unless graphql_resource

          ROUTES.find { |route| route.match(graphql_resource) }&.decorate(self)
        end

        def self.cache_key(request)
          [
            request.path,
            request.headers[GRAPHQL_ETAG_RESOURCE_HEADER]
          ].compact.join(':')
        end
      end
    end
  end
end

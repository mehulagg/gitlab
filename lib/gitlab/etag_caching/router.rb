# frozen_string_literal: true

module Gitlab
  module EtagCaching
    module Router
      Route = Struct.new(:regexp, :name, :feature_category) do
        delegate :match, to: :regexp

        def decorate(router)
          @decorated_route ||= RouteDecorator.new(self, router)
        end
      end

      class RouteDecorator < SimpleDelegator
        attr_reader :router

        delegate :cache_key, to: :router

        def initialize(route, router)
          @router = router

          super(route)
        end
      end

      # Performing RESTful routing match before GraphQL would be more expensive
      # for the GraphQL requests because we need to traverse all of the RESTful
      # route definitions before falling back to GraphQL.
      def self.match(request)
        Router::Graphql.match(request) || Router::Restful.match(request)
      end
    end
  end
end

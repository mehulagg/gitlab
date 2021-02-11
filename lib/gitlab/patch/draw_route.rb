# frozen_string_literal: true

# We're patching `ActionDispatch::Routing::Mapper` in
# config/initializers/routing_draw.rb
module Gitlab
  module Patch
    module DrawRoute
      RoutesNotFound = Class.new(StandardError)

      def draw(routes_name)
        drawn_any = draw_all_routes(routes_name)

        drawn_any || raise(RoutesNotFound.new("Cannot find #{routes_name}"))
      end

      private

      def paths
        Rails.application.config.paths['draw_routes']
      end

      def draw_route_for_path(path, routes_name)
        draw_route(route_path("#{path}/#{routes_name}.rb"))
      end

      def draw_all_routes(routes_name)
        paths.inject(false) do |result, path|
          result | draw_route_for_path(path, routes_name)
        end
      end

      def route_path(routes_name)
        Rails.root.join(routes_name)
      end

      def draw_route(path)
        if File.exist?(path)
          instance_eval(File.read(path))
          true
        else
          false
        end
      end
    end
  end
end


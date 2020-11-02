# frozen_string_literal: true

module EE
  module Gitlab
    module Middleware
      module ReadOnly
        module Controller
          extend ::Gitlab::Utils::Override

          WHITELISTED_GEO_ROUTES = {
            'admin/geo/nodes' => %w{update}
          }.freeze

          WHITELISTED_GEO_ROUTES_TRACKING_DB = {
            'admin/geo/projects' => %w{destroy resync reverify force_redownload resync_all reverify_all},
            'admin/geo/uploads' => %w{destroy}
          }.freeze

          private

          override :whitelisted_routes
          def whitelisted_routes
            super || geo_node_update_route? || geo_proxy_git_ssh_route? || geo_api_route?
          end

          def geo_node_update_route?
            # Calling route_hash may be expensive. Only do it if we think there's a possible match
            return false unless request.path.start_with?('/admin/geo/')

            controller = route_hash[:controller]
            action = route_hash[:action]

            if WHITELISTED_GEO_ROUTES[controller]&.include?(action)
              ::Gitlab::Database.db_read_write?
            else
              WHITELISTED_GEO_ROUTES_TRACKING_DB[controller]&.include?(action)
            end
          end

          def geo_proxy_git_ssh_route?
            ::Gitlab::Middleware::ReadOnly::API_VERSIONS.any? do |version|
              request.path.start_with?("/api/v#{version}/geo/proxy_git_ssh")
            end
          end

          def geo_api_route?
            ::Gitlab::Middleware::ReadOnly::API_VERSIONS.any? do |version|
              request.path.include?("/api/v#{version}/geo_replication")
            end
          end
        end
      end
    end
  end
end

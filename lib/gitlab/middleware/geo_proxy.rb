# frozen_string_literal: true

module Gitlab
  module Middleware
    class GeoProxy < Rack::Proxy
      def perform_request(env)
        request = Rack::Request.new(env)

        if Gitlab::Geo.secondary? && proxy_to_primary?(request)
          primary_http_host = Gitlab::Geo.primary_node.uri.host
          primary_http_host += ":#{Gitlab::Geo.primary_node.uri.port}" unless on_standard_port?(Gitlab::Geo.primary_node.uri.port)

          Rails.logger.info "[GeoProxy] perform_request: Replacing #{env["HTTP_HOST"]} with #{primary_http_host} for path #{request.path}"
          env["HTTP_HOST"] = primary_http_host

          env['content-length'] = nil

          super(env)
        else
          @app.call(env)
        end
      end

      def rewrite_response(triplet)
        _status, headers, _body = triplet
        location = headers["location"]
        location = location.first if location.is_a?(Array)

        if Gitlab::Geo.secondary? && location.present? && rewrite_response_location?(location)
          Rails.logger.info "[GeoProxy] rewrite_response: headers before #{headers.inspect}"

          primary_http_host = Gitlab::Geo.primary_node.uri.host
          primary_http_host += ":#{Gitlab::Geo.primary_node.uri.port}" unless on_standard_port?(Gitlab::Geo.primary_node.uri.port)
          this_http_host = Settings.gitlab.url.sub(%r{.*://}, '')

          Rails.logger.info "[GeoProxy] rewrite_response: Replacing #{primary_http_host} with #{this_http_host} in #{location}"
          headers["location"] = location.sub(primary_http_host, this_http_host) if location.include?(primary_http_host)

          # if you proxy depending on the backend, it appears that content-length isn't calculated correctly
          # resulting in only partial responses being sent to users
          # you can remove it or recalculate it here
          headers["content-length"] = nil

          Rails.logger.info "[GeoProxy] rewrite_response: headers after #{headers.inspect}"
        end

        triplet
      end

      def proxy_to_primary?(request)
        # Do not proxy these paths to the primary
        authentication_paths = %w{
          /users/
          /sessions/
          /oauth/
        }

        is_authentication_request = authentication_paths.any? { |path| request.path.start_with?(path) }
        return if is_authentication_request

        # TODO: This is surely not specific enough
        is_git_request = request.path.include?('.git/')
        return if is_git_request

        true
      end

      def on_standard_port?(port)
        %w{80 443}.include?(port)
      end

      def rewrite_response_location?(location)
        # If redirecting to any of these locations,
        # then do not modify the host.
        valid_locations = %w{
          /users/sign_in
          /users/sign_out
          /sessions
          /oauth/authorize
          /oauth/geo/auth
          /oauth/geo/callback
          /oauth/geo/logout
        }

        valid_locations.none? { |v| location.match(v) }
      end
    end
  end
end

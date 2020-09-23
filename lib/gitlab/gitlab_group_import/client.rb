# frozen_string_literal: true

module Gitlab
  module GitlabGroupImport
    class Client
      NETWORK_ERRORS = [
        SocketError,
        OpenSSL::SSL::SSLError,
        Errno::ECONNRESET,
        Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH,
        Net::OpenTimeout,
        Net::ReadTimeout,
        Gitlab::HTTP::BlockedUrlError
      ].freeze

      API_VERSION = 'v4'

      ConnectionError = Class.new(StandardError)

      def initialize(uri:, token:, per_page: 20, api_version: API_VERSION)
        @uri = URI.parse(uri)
        @token = token&.strip
        @per_page = per_page
        @api_version = api_version
      end

      def get(resource, query = {})
        response = with_error_handling do
          Gitlab::HTTP.get(
            resource_url(resource),
            headers: request_headers,
            query: query
          )
        end

        response.parsed_response
      end

      private

      def request_params
        {
          headers: request_headers,
          follow_redirects: false
        }
      end

      def request_headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@token}"
        }
      end

      def with_error_handling
        response = yield

        raise ConnectionError.new("Error #{response.code}") unless response.success?

        response
      rescue *NETWORK_ERRORS => e
        raise ConnectionError, e
      end

      def base_uri
        @base_uri ||= "#{@uri.scheme}://#{@uri.host}:#{@uri.port}"
      end

      def api_url
        Gitlab::Utils.append_path(base_uri, "/api/#{@api_version}")
      end

      def resource_url(resource)
        Gitlab::Utils.append_path(api_url, resource)
      end
    end
  end
end

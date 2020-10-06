# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

module Gitlab
  module BulkImport
    class GraphqlClient
      def initialize(url: 'https://gitlab.com')
        @url = url
        @http = GraphQL::Client::HTTP.new(graphql_endpoint)

        Schema = 1


      end

      def graphql_endpoint
        Gitlab::Utils.append_path(base_uri, "/api/#{@api_version}")
      end

      HTTP = ::

      Schema = ::

      Client = ::GraphQL::Client.new(schema: Schema, execute: HTTP)
    end
  end
end

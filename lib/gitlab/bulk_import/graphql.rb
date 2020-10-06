# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

module Gitlab
  module BulkImport
    module Graphql
      class Client
        def initialize(url: 'https://gitlab.com/api/graphql')
          @url    = url
          @http   = GraphQL::Client::HTTP.new(@url)
          @schema = GraphQL::Client.load_schema(@http)
          @client = GraphQL::Client.new(schema: @schema, execute: @http)
        end

        def graphql_endpoint
          Gitlab::Utils.append_path(@url, "/api/#{@api_version}")
        end
      end
    end
  end
end

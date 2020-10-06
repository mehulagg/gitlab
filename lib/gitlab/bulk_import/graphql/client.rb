# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Graphql
      class Client
        delegate :query, :parse, :execute, to: :@client

        def initialize(url: 'https://gitlab.com', token: nil)
          @url = Gitlab::Utils.append_path(url, '/api/graphql')
          @token = token
          @client = Graphlient::Client.new(
            @url,
            request_headers
          )
        end

        def request_headers
          return {} unless @token

          {
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => "Bearer #{@token}"
            }
          }
        end
      end
    end
  end
end

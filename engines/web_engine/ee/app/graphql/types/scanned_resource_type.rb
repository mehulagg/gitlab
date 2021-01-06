# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ScannedResourceType < BaseObject
    graphql_name 'ScannedResource'
    description 'Represents a resource scanned by a security scan'

    field :url, GraphQL::STRING_TYPE, null: true, description: 'The URL scanned by the scanner'
    field :request_method, GraphQL::STRING_TYPE, null: true, description: 'The HTTP request method used to access the URL'
  end
end

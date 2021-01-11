# frozen_string_literal: true

module Types
  module Packages
    module Composer
      class JsonType < BaseObject
        graphql_name 'PackageComposerJsonType'
        description 'Represents a composer JSON file'
        authorize :read_package

        field :name, GraphQL::STRING_TYPE, null: true, description: 'The name set in the composer JSON file.'
        field :type, GraphQL::STRING_TYPE, null: true, description: 'The type set in the composer JSON file.'
        field :license, GraphQL::STRING_TYPE, null: true, description: 'The license set in the composer JSON file.'
        field :version, GraphQL::STRING_TYPE, null: true, description: 'The version set in the composer JSON file.'
      end
    end
  end
end

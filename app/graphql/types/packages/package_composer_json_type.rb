# frozen_string_literal: true

module Types
  module Packages
    class PackageComposerJsonType < BaseObject
      graphql_name 'PackageComposerJsonType'
      description 'Represents a composer json file'
      authorize :read_package

      field :name, GraphQL::STRING_TYPE, null: true, description: 'The name set in the composer.json file.'
      field :type, GraphQL::STRING_TYPE, null: true, description: 'The type set in the composer.json file.'
      field :license, GraphQL::STRING_TYPE, null: true, description: 'The license set in the composer.json file.'
      field :version, GraphQL::STRING_TYPE, null: true, description: 'The version set in the composer.json file.'
    end
  end
end

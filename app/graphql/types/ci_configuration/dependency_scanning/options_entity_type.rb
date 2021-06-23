# frozen_string_literal: true

module Types
  module CiConfiguration
    module DependencyScanning
      # rubocop: disable Graphql/AuthorizeTypes
      class OptionsEntityType < BaseObject
        graphql_name 'DependencyScanningCiConfigurationOptionsEntity'
        description 'Represents an entity for options in Dependency Scanning CI configuration'

        field :label, GraphQL::STRING_TYPE, null: true,
          description: 'Label of option entity.'

        field :value, GraphQL::STRING_TYPE, null: true,
          description: 'Value of option entity.'
      end
    end
  end
end

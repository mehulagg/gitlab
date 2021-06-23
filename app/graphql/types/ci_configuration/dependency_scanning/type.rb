# frozen_string_literal: true

module Types
  module CiConfiguration
    module DependencyScanning
      # rubocop: disable Graphql/AuthorizeTypes
      class Type < BaseObject
        graphql_name 'DependencyScanningCiConfiguration'
        description 'Represents a CI configuration of Dependency Scanning'

        field :global, ::Types::CiConfiguration::DependencyScanning::EntityType.connection_type, null: true,
          description: 'List of global entities related to Dependency Scanning configuration.'

        field :pipeline, ::Types::CiConfiguration::DependencyScanning::EntityType.connection_type, null: true,
          description: 'List of pipeline entities related to Dependency Scanning configuration.'

        field :analyzers, ::Types::CiConfiguration::DependencyScanning::AnalyzersEntityType.connection_type, null: true,
          description: 'List of analyzers entities attached to Dependency Scanning configuration.'
      end
    end
  end
end

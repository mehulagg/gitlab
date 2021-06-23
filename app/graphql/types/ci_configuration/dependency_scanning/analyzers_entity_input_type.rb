# frozen_string_literal: true

module Types
  module CiConfiguration
    module DependencyScanning
      class AnalyzersEntityInputType < BaseInputObject
        graphql_name 'DependencyScanningCiConfigurationAnalyzersEntityInput'
        description 'Represents the analyzers entity in Dependency Scanning CI configuration'

        argument :name, GraphQL::STRING_TYPE, required: true,
          description: 'Name of analyzer.'

        argument :enabled, GraphQL::BOOLEAN_TYPE, required: true,
          description: 'State of the analyzer.'

        argument :variables, [::Types::CiConfiguration::DependencyScanning::EntityInputType],
          description: 'List of variables for the analyzer.',
          required: false
      end
    end
  end
end

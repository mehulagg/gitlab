# frozen_string_literal: true

module Types
  module CiConfiguration
    module DependencyScanning
      class InputType < BaseInputObject
        graphql_name 'DependencyScanningCiConfigurationInput'
        description 'Represents a CI configuration of Dependency Scanning'

        argument :global, [::Types::CiConfiguration::DependencyScanning::EntityInputType],
          description: 'List of global entities related to Dependency Scanning configuration.',
          required: false

        argument :pipeline, [::Types::CiConfiguration::DependencyScanning::EntityInputType],
          description: 'List of pipeline entities related to Dependency Scanning configuration.',
          required: false

        argument :analyzers, [::Types::CiConfiguration::DependencyScanning::AnalyzersEntityInputType],
          description: 'List of analyzers and related variables for the Dependency Scanning configuration.',
          required: false
      end
    end
  end
end

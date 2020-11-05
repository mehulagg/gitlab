# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class SecurityScanners < BaseObject
    graphql_name 'SecurityScanners'
    description 'Represents a list of security scanners'

    field :enabled, [::Types::SecurityScannerTypeEnum], null: true,
      description: 'List of analyzers which are enabled for the project.',
      calls_gitaly: true,
      resolve: -> (project, _args, ctx) do
        project.enabled_scanners
      end

    field :available, [::Types::SecurityScannerTypeEnum], null: true,
      description: 'List of analyzers which are available for the project.',
      resolve: -> (project, _args, ctx) do
        project.available_scanners
      end

    field :pipeline_run, [::Types::SecurityScannerTypeEnum], null: true,
      description: 'List of analyzers which ran successfully in the latest pipeline.',
      calls_gitaly: true,
      resolve: -> (project, _args, ctx) do
        project.scanners_run_in_last_pipeline
      end
  end
end

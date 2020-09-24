# frozen_string_literal: true

module Types
  class DastScannerProfileType < BaseObject
    graphql_name 'DastScannerProfile'
    description 'Represents a DAST scanner profile'

    authorize :create_on_demand_dast_scan

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the DAST scanner profile',
          deprecated: { reason: 'Use `global_id`', milestone: '13.4' }

    field :global_id, ::Types::GlobalIDType[::DastScannerProfile], null: false,
          description: 'ID of the DAST scanner profile',
          method: :id

    field :profile_name, GraphQL::STRING_TYPE, null: true,
          description: 'Name of the DAST scanner profile',
          method: :name

    field :spider_timeout, GraphQL::INT_TYPE, null: true,
          description: 'The maximum number of minutes allowed for the spider to traverse the site'

    field :target_timeout, GraphQL::INT_TYPE, null: true,
          description: 'The maximum number of seconds allowed for the site under test to respond to a request'

    field :edit_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the edit page of a scanner profile',
          resolve: -> (obj, _args, _ctx) do
            Rails.application.routes.url_helpers.edit_project_security_configuration_dast_profiles_dast_scanner_profile_path(obj.project, obj)
          end
  end
end

# frozen_string_literal: true

module Types
  class DastScannerProfileType < BaseObject
    graphql_name 'DastScannerProfile'
    description 'Represents a DAST scanner profile'

    authorize :create_on_demand_dast_scan

    field :id, ::Types::GlobalIDType[::DastScannerProfile], null: false,
          description: 'ID of the DAST scanner profile'

    field :global_id, ::Types::GlobalIDType[::DastScannerProfile], null: false,
          description: 'ID of the DAST scanner profile',
          deprecated: { reason: 'Use `id`', milestone: '13.6' },
          method: :id

    field :profile_name, GraphQL::STRING_TYPE, null: true,
          description: 'Name of the DAST scanner profile',
          method: :name

    field :spider_timeout, GraphQL::INT_TYPE, null: true,
          description: 'The maximum number of minutes allowed for the spider to traverse the site'

    field :target_timeout, GraphQL::INT_TYPE, null: true,
          description: 'The maximum number of seconds allowed for the site under test to respond to a request'

    field :scan_type, Types::DastScanTypeEnum, null: true,
          description: 'Indicates the type of DAST scan that will run. ' \
          'Either a Passive Scan or an Active Scan.'

    field :use_ajax_spider, GraphQL::BOOLEAN_TYPE, null: false,
          description: 'Indicates if the AJAX spider should be used to crawl the target site. ' \
          'True to run the AJAX spider in addition to the traditional spider, and false to run only the traditional spider.'

    field :show_debug_messages, GraphQL::BOOLEAN_TYPE, null: false,
          description: 'Indicates if debug messages should be included in DAST console output. ' \
          'True to include the debug messages.'

    field :edit_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the edit page of a scanner profile',
          resolve: -> (obj, _args, _ctx) do
            Rails.application.routes.url_helpers.edit_project_security_configuration_dast_profiles_dast_scanner_profile_path(obj.project, obj)
          end
  end
end

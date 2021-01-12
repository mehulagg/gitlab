# frozen_string_literal: true

module Mutations
  module DastScans
    class Create < BaseMutation
      include FindsProject

      graphql_name 'DastScanCreate'

      field :dast_scan, ::Types::DastScanType,
            null: true,
            description: 'The created scan.'

      field :pipeline_url, GraphQL::STRING_TYPE,
            null: false,
            description: 'The URL of the pipeline that was created. Requires `runAfterCreate` to be true.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the scan belongs to.'

      argument :name, GraphQL::STRING_TYPE,
               required: true,
               description: 'The name of the scan.'

      argument :description, GraphQL::STRING_TYPE,
               required: false,
               description: 'The description of the scan.',
               default_value: ''

      argument :dast_site_profile_id, ::Types::GlobalIDType[::DastSiteProfile],
               required: true,
               description: 'ID of the site profile to be used for the scan.'

      argument :dast_scanner_profile_id, ::Types::GlobalIDType[::DastScannerProfile],
               required: true,
               description: 'ID of the scanner profile to be used for the scan.'

      argument :run_after_create, GraphQL::BOOLEAN_TYPE,
               required: false,
               description: 'Run scan after creation.',
               default_value: false

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, name:, description:, dast_site_profile_id:, dast_site_scanner_id:, run_after_create:)
        _ = authorized_find!(full_path)

        { dast_scan: nil, pipeline_url: nil, errors: [] }
      end
    end
  end
end

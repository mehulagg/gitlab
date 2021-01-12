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

      def resolve(full_path:, name:, description: '', dast_site_profile_id:, dast_scanner_profile_id:, run_after_create: false)
        project = authorized_find!(full_path)

        # TODO: remove explicit coercion once compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        site_profile_id = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(dast_site_profile_id)
        scanner_profile_id = ::Types::GlobalIDType[::DastScannerProfile].coerce_isolated_input(dast_scanner_profile_id)

        dast_site_profile = project.dast_site_profiles.find(site_profile_id.model_id)
        dast_scanner_profile = project.dast_scanner_profiles.find(scanner_profile_id.model_id)

        dast_scan = DastScan.create(
          project: project,
          name: name,
          description: description,
          dast_site_profile: dast_site_profile,
          dast_scanner_profile: dast_scanner_profile
        )

        { dast_scan: dast_scan, pipeline_url: nil, errors: [] }
      end
    end
  end
end

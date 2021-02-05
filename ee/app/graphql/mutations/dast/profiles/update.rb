# frozen_string_literal: true

module Mutations
  module Dast
    module Profiles
      class Create < BaseMutation
        include FindsProject

        graphql_name 'DastProfileCreate'

        SiteProfileID = ::Types::GlobalIDType[::DastSiteProfile]
        ScannerProfileID = ::Types::GlobalIDType[::DastScannerProfile]

        field :dast_profile, ::Types::Dast::ProfileType,
              null: true,
              description: 'The updated profile.'

        field :pipeline_url, GraphQL::STRING_TYPE,
              null: true,
              description: 'The URL of the pipeline that was created. Requires `runAfterCreate` to be set to `true`.'

        argument :full_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project the profile belongs to.'

        argument :name, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The name of the profile.'

        argument :description, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The description of the profile. Defaults to an empty string.',
                 default_value: ''

        argument :dast_site_profile_id, SiteProfileID,
                 required: false,
                 description: 'ID of the site profile to be associated.'

        argument :dast_scanner_profile_id, ScannerProfileID,
                 required: false,
                 description: 'ID of the scanner profile to be associated.'

        argument :run_after_create, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 description: 'Run scan using profile after creation. Defaults to false.',
                 default_value: false

        authorize :create_on_demand_dast_scan

        def resolve(run_after_create: false, **args)
          project = authorized_find!(full_path)
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled' unless allowed?(project)

          # TODO: remove explicit coercion once compatibility layer is removed
          # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
          site_profile_id = args[:dast_site_profile_id] && SiteProfileID.coerce_isolated_input(args[:dast_site_profile_id])
          scanner_profile_id = args[:dast_scanner_profile_id] && ScannerProfileID.coerce_isolated_input(args[:dast_scanner_profile_id])

          update_service_response = update_profile(
            name: args[:name],
            description: args[:description],
            dast_site_profile: site_profile_id.model_id,
            dast_scanner_profile: scanner_profile_id.model_id
          )

          error_response(update_service_response.errors) if update_service_response.error?

          dast_profile = update_service_response.payload

          return success_response(dast_profile: dast_profile) unless run_after_create

          scan_response = create_scan(
            dast_site_profile: dast_profile.dast_site_profile,
            dast_scanner_profile: dast_profile.dast_scanner_profile
          )

          return error_response(scan_response.errors) if scan_response.error?

          pipeline_url = scan_response.payload.fetch(:pipeline_url)

          success_response(dast_profile: dast_profile, pipeline_url: pipeline_url)
        end

        private

        def allowed?(project)
          project.feature_available?(:security_on_demand_scans) &&
            Feature.enabled?(:dast_saved_scans, project, default_enabled: :yaml)
        end

        def error_response(errors)
          { errors: errors }
        end

        def success_response(payload)
          { errors: [] }.merge!(payload)
        end

        def update_profile(params)
          ::Dast::Profiles::UpdateService.new(
            container: project,
            current_user: current_user,
            params: params
          ).execute
        end

        def create_scan(params)
          ::DastOnDemandScans::CreateService.new(
            container: container,
            current_user: current_user,
            params: params
          ).execute
        end
      end
    end
  end
end

# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Update < BaseMutation
      include FindsProject

      graphql_name 'DastSiteProfileUpdate'

      field :id, ::Types::GlobalIDType[::DastSiteProfile],
            null: true,
            description: 'ID of the site profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :id, ::Types::GlobalIDType[::DastSiteProfile],
               required: true,
               description: 'ID of the site profile to be updated.'

      argument :profile_name, GraphQL::STRING_TYPE,
               required: true,
               description: 'The name of the site profile.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the target to be scanned.'

      argument :excluded_urls, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URLs to skip during an authenticated scan. Will be ignored ' \
                            'if `security_dast_site_profiles_additional_fields` feature flag is disabled.'

      argument :request_headers, GraphQL::STRING_TYPE,
               required: false,
               description: 'Comma-separated list of request header names and values to be ' \
                            'added to every request made by DAST. Will be ignored ' \
                            'if `security_dast_site_profiles_additional_fields` feature flag is disabled.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, id:, request_headers: nil, **service_args)
        # TODO: remove explicit coercion once compatibility layer has been removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        service_args[:id] = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(id).model_id
        project = authorized_find!(full_path)

        service = ::DastSiteProfiles::UpdateService.new(project, current_user)
        result = service.execute(**service_args)

        if result.success?
          { id: result.payload.to_global_id, errors: [] }
        else
          { errors: result.errors }
        end
      end
    end
  end
end

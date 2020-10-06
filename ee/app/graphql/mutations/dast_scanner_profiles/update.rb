# frozen_string_literal: true

module Mutations
  module DastScannerProfiles
    class Update < BaseMutation
      include ResolvesProject

      graphql_name 'DastScannerProfileUpdate'

      field :id, ::Types::GlobalIDType[::DastScannerProfile],
            null: true,
            description: 'ID of the scanner profile.'

      argument :full_path, GraphQL::ID_TYPE,
                required: true,
                description: 'The project the scanner profile belongs to.'

      argument :id, ::Types::GlobalIDType[::DastScannerProfile],
                required: true,
                description: 'ID of the scanner profile to be updated.'

      argument :profile_name, GraphQL::STRING_TYPE,
                required: true,
                description: 'The name of the scanner profile.'

      argument :spider_timeout, GraphQL::INT_TYPE,
                required: true,
                description: 'The maximum number of minutes allowed for the spider to traverse the site.'

      argument :target_timeout, GraphQL::INT_TYPE,
                required: true,
                description: 'The maximum number of seconds allowed for the site under test to respond to a request.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, **service_args)
        # TODO: remove this explicit coercion once the compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        gid = ::Types::GlobalIDType[::DastScannerProfile].coerce_isolated_input(service_args[:id])

        project = authorized_find!(full_path: full_path)

        service = ::DastScannerProfiles::UpdateService.new(project, current_user)
        result = service.execute({ **service_args, id: gid.model_id })

        if result.success?
          { id: result.payload.to_global_id, errors: [] }
        else
          { errors: result.errors }
        end
      end

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end

# frozen_string_literal: true

module Mutations
  module Dast
    module Profiles
      class Delete < BaseMutation
        include FindsProject

        graphql_name 'DastProfileDelete'

        ProfileID = ::Types::GlobalIDType[::Dast::Profile]

        argument :full_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'Full path for the project the scanner profile belongs to.'

        argument :id, ProfileID,
                 required: true,
                 description: 'ID of the profile to be deleted.'

        authorize :create_on_demand_dast_scan

        def resolve(full_path:, id:)
          project = authorized_find!(full_path)
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled' unless allowed?(project)

          # TODO: remove this line once the compatibility layer is removed
          # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
          id = ProfileID.coerce_isolated_input(id).model_id

          response = ::Dast::Profiles::DestroyService.new(
            container: project,
            current_user: current_user,
            params: { id: id }
          ).execute

          return { errors: response.errors } if response.error?

          { errors: [] }
        end

        private

        def allowed?(project)
          project.feature_available?(:security_on_demand_scans) &&
            Feature.enabled?(:dast_saved_scans, project, default_enabled: :yaml)
        end
      end
    end
  end
end

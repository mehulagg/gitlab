# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Delete < BaseMutation
      graphql_name 'DastSiteProfileDelete'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :id, ::Types::GlobalIDType[::DastSiteProfile],
               required: true,
               description: 'ID of the site profile to be deleted.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, id:)
        project = authorized_find!(full_path)
        # TODO: remove explicit coercion once compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(id)

        dast_site_profile = find_dast_site_profile(project: project, global_id: id)

        return { errors: dast_site_profile.errors.full_messages } unless dast_site_profile.destroy

        { errors: [] }
      rescue ActiveRecord::RecordNotFound
        raise_resource_not_available_error!
      end

      private

      def find_object(full_path)
        Project.find_by_full_path(full_path)
      end

      def find_dast_site_profile(project:, global_id:)
        project.dast_site_profiles.find(global_id.model_id)
      rescue ActiveRecord::RecordNotFound
        raise_resource_not_available_error!
      end
    end
  end
end

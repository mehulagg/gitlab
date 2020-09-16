# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Delete < BaseMutation
      include AuthorizesProject

      graphql_name 'DastSiteProfileDelete'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :id, ::Types::GlobalIDType[::DastSiteProfile],
               required: true,
               description: 'ID of the site profile to be deleted.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, id:)
        project = authorized_find_project!(full_path: full_path)
        # TODO: remove explicit coercion once compatibility layer is removed
        id = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(id)
        raise_resource_not_available_error! unless Feature.enabled?(:security_on_demand_scans_feature_flag, project, default_enabled: true)

        dast_site_profile = find_dast_site_profile(project: project, global_id: id)

        return { errors: dast_site_profile.errors.full_messages } unless dast_site_profile.destroy

        { errors: [] }
      end

      private

      def find_dast_site_profile(project:, global_id:)
        project.dast_site_profiles.find(global_id.model_id)
      end
    end
  end
end

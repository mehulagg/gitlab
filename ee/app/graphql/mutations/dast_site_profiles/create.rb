# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Create < BaseMutation
      include ResolvesProject

      graphql_name 'DastSiteProfileCreate'

      field :id, GraphQL::ID_TYPE,
            null: true,
            description: 'ID of the site profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :profile_name, GraphQL::STRING_TYPE,
               required: true,
               description: 'The name of the site profile.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the target to be scanned.'

      authorize :run_ondemand_dast_scan

      def resolve(full_path:, profile_name:, target_url: nil)
        project = authorized_find!(full_path: full_path)
        raise_resource_not_available_error! unless Feature.enabled?(:security_on_demand_scans_feature_flag, project)

        service = ::DastSiteProfiles::CreateService.new(project, current_user)
        result = service.execute(name: profile_name, target_url: target_url)

        if result.success?
          { id: result.payload.to_global_id, errors: [] }
        else
          # Rails.logger.error("*" * 80)
          # Rails.logger.error("failed")
          # Rails.logger.error(result.errors)
          # Rails.logger.error("*" * 80)

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

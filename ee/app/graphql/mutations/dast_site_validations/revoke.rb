# frozen_string_literal: true

module Mutations
  module DastSiteValidations
    class Revoke < BaseMutation
      FEATURE_FLAG = :security_on_demand_scans_site_validation

      include FindsProject

      graphql_name 'DastSiteValidationRevoke'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site validation belongs to.'

      argument :normalized_target_url, GraphQL::STRING_TYPE,
               required: true,
               description: 'Normalized URL of the target to be revoked.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, normalized_target_url:)
        project = authorized_find!(full_path)
        raise Gitlab::Graphql::Errors::ResourceNotAvailable, "Feature disabled: #{FEATURE_FLAG}" unless allowed?(project)

        response = ::DastSiteValidations::RevokeService.new(
          container: project,
          params: { url_base: normalized_target_url }
        ).execute

        return error_response(response.errors) if response.error?

        success_response
      end

      private

      def allowed?(project)
        Feature.enabled?(FEATURE_FLAG, project, default_enabled: :yaml)
      end

      def error_response(errors)
        { errors: errors }
      end

      def success_response
        { errors: [] }
      end
    end
  end
end

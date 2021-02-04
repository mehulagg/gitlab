# frozen_string_literal: true

module Dast
  module Profiles
    class DestroyService < BaseContainerService
      def execute
        return unauthorized unless allowed?
        return ServiceResponse.error(message: 'ID parameter missing') unless params[:id]

        dast_profile = find_dast_profile
        return ServiceResponse.error(message: 'Profile not found for given parameters') unless dast_profile

        ServiceResponse.error(message: 'Profile failed to delete') unless dast_profile.destroy

        ServiceResponse.success(payload: dast_profile)
      end

      private

      def allowed?
        container.feature_available?(:security_on_demand_scans) &&
          Feature.enabled?(:dast_saved_scans, container, default_enabled: :yaml) &&
          can?(current_user, :create_on_demand_dast_scan, container)
      end

      def unauthorized
        ::ServiceResponse.error(
          message: 'You are not authorized to update this profile',
          http_status: 403
        )
      end

      def find_dast_profile
        ::Dast::ProfilesFinder.new(project_id: container, id: params[:id])
          .execute
          .first
      end
    end
  end
end

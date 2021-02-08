# frozen_string_literal: true

module Dast
  module Profiles
    class UpdateService < BaseContainerService
      include Gitlab::Utils::StrongMemoize

      def execute
        return unauthorized unless allowed?
        return ServiceResponse.error(message: 'ID parameter missing') unless params[:id].present?
        return ServiceResponse.error(message: 'Profile not found for given parameters') unless dast_profile

        return ServiceResponse.error(message: dast_profile.errors.full_messages) unless dast_profile.update(dast_profile_params)

        ServiceResponse.success(payload: dast_profile)
      end

      private

      def allowed?
        container.feature_available?(:security_on_demand_scans) &&
          Feature.enabled?(:dast_saved_scans, container, default_enabled: :yaml) &&
          can?(current_user, :create_on_demand_dast_scan, container)
      end

      def unauthorized
        ServiceResponse.error(
          message: 'You are not authorized to update this profile',
          http_status: 403
        )
      end

      def dast_profile
        strong_memoize(:dast_profile) do
          Dast::ProfilesFinder.new(project_id: container.id, id: params[:id])
            .execute
            .first
        end
      end

      def dast_profile_params
        params.slice(:dast_site_profile_id, :dast_scanner_profile_id, :name, :description)
      end
    end
  end
end

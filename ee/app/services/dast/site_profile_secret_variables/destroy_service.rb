# frozen_string_literal: true

module Dast
  module SiteProfileSecretVariables
    class DestroyService < BaseContainerService
      def execute
        return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?
        return ServiceResponse.error(message: 'Variable parameter missing') unless dast_site_profile_secret_variable
        return ServiceResponse.error(message: 'Variable failed to delete') unless dast_site_profile_secret_variable.destroy

        ServiceResponse.success(payload: dast_site_profile_secret_variable)
      end

      private

      def allowed?
        Feature.enabled?(:security_dast_site_profiles_additional_fields, container, default_enabled: :yaml) &&
          Ability.allowed?(current_user, :create_on_demand_dast_scan, container)
      end

      def dast_site_profile_secret_variable
        params[:dast_site_profile_secret_variable]
      end
    end
  end
end

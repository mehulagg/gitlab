# frozen_string_literal: true

module DastSiteValidations
  class RevokeService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      normalized_target_url = params.fetch(:normalized_target_url)

      ServiceResponse.success(payload: normalized_target_url)
    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    rescue KeyError => err
      ServiceResponse.error(message: err.message.capitalize)
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:security_on_demand_scans_site_validation, container, default_enabled: :yaml)
    end
  end
end

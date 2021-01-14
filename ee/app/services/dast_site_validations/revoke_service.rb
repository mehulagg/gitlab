# frozen_string_literal: true

module DastSiteValidations
  class RevokeService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      finder = DastSiteValidationsFinder.new(
        project_id: container.id,
        url_base: params.fetch(:url_base),
        state: :passed
      )

      result = finder.execute.delete_all

      ServiceResponse.success(payload: { count: result })
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

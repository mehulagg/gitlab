# frozen_string_literal: true

module DastSiteValidations
  class RevokeService < BaseContainerService
    MissingParamError = Class.new(StandardError)

    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      finder = DastSiteValidationsFinder.new(
        project_id: container.id,
        url_base: url_base,
        state: :passed
      )

      result = finder.execute.delete_all

      ServiceResponse.success(payload: { count: result })
    rescue MissingParamError => err
      ServiceResponse.error(message: err.message)
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:security_on_demand_scans_site_validation, container, default_enabled: :yaml)
    end

    def url_base
      params[:url_base] || raise(MissingParamError, 'URL parameter used to search for validations is missing')
    end
  end
end

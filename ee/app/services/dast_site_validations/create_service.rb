# frozen_string_literal: true

module DastSiteValidations
  class CreateService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      dast_site_token = params.fetch(:dast_site_token)
      url_path = params.fetch(:url_path)
      validation_strategy = params.fetch(:validation_strategy)

      dast_site_validation = DastSiteValidation.create!(
        dast_site_token: dast_site_token,
        url_path: url_path,
        validation_strategy: validation_strategy
      )

      ServiceResponse.success(payload: dast_site_validation)
    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:security_on_demand_scans_site_validation, container)
    end
  end
end

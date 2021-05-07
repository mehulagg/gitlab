# frozen_string_literal: true

module DastSiteTokens
  class CreateService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      target_url = params[:target_url]
      url_base = normalize_target_url(target_url)

      dast_site_token = DastSiteToken.create!(
        project: container,
        token: SecureRandom.uuid,
        url: target_url
      )

      dast_site_validation = find_dast_site_validation(url_base)
      status = calculate_status(dast_site_validation)

      ServiceResponse.success(
        payload: { dast_site_token: dast_site_token, status: status }
      )
    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    rescue URI::InvalidURIError
      ServiceResponse.error(message: 'Invalid target_url')
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans)
    end

    def normalize_target_url(target_url)
      DastSiteValidation.get_normalized_url_base(target_url)
    end

    def find_dast_site_validation(url_base)
      DastSiteValidationsFinder.new(project_id: container.id, url_base: url_base)
        .execute
        .first
    end

    def calculate_status(dast_site_validation)
      dast_site_validation&.state || DastSiteValidation::INITIAL_STATE
    end
  end
end

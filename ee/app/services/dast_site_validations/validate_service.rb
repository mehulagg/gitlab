# frozen_string_literal: true

module DastSiteValidations
  class ValidateService < BaseContainerService
    PermissionsError = Class.new(StandardError)
    TokenNotFound = Class.new(StandardError)

    def execute!
      raise PermissionsError.new('Insufficient permissions') unless allowed?

      return if dast_site_validation.passed?

      if dast_site_validation.pending?
        dast_site_validation.start
      else
        dast_site_validation.retry
      end

      response = make_http_request!

      validate!(response)
    end

    private

    def allowed?
      container.feature_available?(:security_on_demand_scans) &&
        Feature.enabled?(:security_on_demand_scans_site_validation, container)
    end

    def dast_site_validation
      @dast_site_validation ||= params.fetch(:dast_site_validation)
    end

    def make_http_request!
      uri, _ = Gitlab::UrlBlocker.validate!(dast_site_validation.validation_url)
      Gitlab::HTTP.get(uri)
    end

    def token_found?(response)
      response.body.include?(dast_site_validation.dast_site_token.token)
    end

    def validate!(response)
      raise TokenNotFound.new('Could not find token in response body') unless token_found?(response)

      dast_site_validation.pass
    end
  end
end

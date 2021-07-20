# frozen_string_literal: true

module DastSiteValidations
  class ValidateService < BaseContainerService
    PermissionsError = Class.new(StandardError)
    TokenNotFound = Class.new(StandardError)

    def execute!
      raise PermissionsError, 'Insufficient permissions' unless allowed?

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
      container.feature_available?(:security_on_demand_scans)
    end

    def dast_site_validation
      @dast_site_validation ||= params.fetch(:dast_site_validation)
    end

    def make_http_request!
      Gitlab::HTTP.get(dast_site_validation.validation_url, use_read_total_timeout: true)
    end

    def token_found?(response)
      token = dast_site_validation.dast_site_token.token

      case dast_site_validation.validation_strategy
      when 'text_file'
        response.content_type == 'text/plain' && response.body.rstrip == token
      when 'header'
        response.headers[DastSiteValidation::HEADER] == token
      else
        false
      end
    end

    def validate!(response)
      raise TokenNotFound, 'Could not find token' unless token_found?(response)

      dast_site_validation.pass
    end
  end
end

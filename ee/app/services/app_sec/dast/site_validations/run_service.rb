# frozen_string_literal: true

module AppSec
  module Dast
    module SiteValidations
      class RunService < BaseContainerService
        def execute
        end

        private

        def allowed?
          container.licensed_feature_available?(:security_on_demand_scans)
        end

        def ci_config
          {
            stages: [:dast],
            validation: {
              stage: :dast,
              image: '192.168.99.103:5001/root/dast-validation-runner:latest',
              script: ['~/validate.sh'],
              variables: {
                GIT_STRATEGY => 'none',
                DAST_SITE_VALIDATION_ID: dast_site_validation.id,
                DAST_SITE_VALIDATION_HEADER: ::DastSiteValidation::HEADER,
                DAST_SITE_VALIDATION_STRATEGY: dast_site_validation.validation_strategy,
                DAST_SITE_VALIDATION_TOKEN: dast_site_validation.dast_site_token.token,
                DAST_SITE_VALIDATION_URL: dast_site_validation.validation_url
              }
            }
          }
        end
      end
    end
  end
end

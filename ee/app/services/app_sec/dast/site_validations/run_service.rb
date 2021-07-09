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
            'stages' => ['dast'],
            'dast-runner-validation' =>  {
              'stage' => 'dast',
              'image' => '192.168.99.103:5001/root/dast-validation-runner:latest',
              'variables'  =>  {
                'GIT_STRATEGY' => 'none',
                'DAST_SITE_VALIDATION_ID' => 4,
                'DAST_SITE_VALIDATION_HEADER' => 'Gitlab-On-Demand-DAST',
                'DAST_SITE_VALIDATION_STRATEGY' => 'header',
                'DAST_SITE_VALIDATION_TOKEN' => 'ad568ddc-eecc-4d06-85ee-147489b1ee2d',
                'DAST_SITE_VALIDATION_URL' => 'https://2ecd79974152.ngrok.io:443/validate'
              },
              'script' => ['~/validate.sh']
            }
          }
        end
      end
    end
  end
end

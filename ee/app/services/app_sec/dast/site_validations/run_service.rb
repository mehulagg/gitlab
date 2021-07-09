# frozen_string_literal: true

module AppSec
  module Dast
    module SiteValidations
      class RunService < BaseProjectService
        def execute
          service = Ci::CreatePipelineService.new(project, current_user, ref: project.default_branch_or_main)
          pipeline = service.execute(:ondemand_dast_scan, content: ci_configuration.to_yaml)

          if pipeline.created_successfully?
            ServiceResponse.success(payload: dast_site_validation)
          else
            ServiceResponse.error(message: pipeline.full_error_messages)
          end
        end

        private

        def allowed?
          can?(current_user, :create_on_demand_dast_scan, project)
        end

        def ci_configuration
          {
            'stages' => ['dast'],
            'validation' => {
              'stage' => 'dast',
              'image' => '192.168.99.103:5001/root/dast-validation-runner:latest',
              'variables' => {
                'GIT_STRATEGY' => 'none',
                'DAST_SITE_VALIDATION_ID' => dast_site_validation.id,
                'DAST_SITE_VALIDATION_HEADER' => ::DastSiteValidation::HEADER,
                'DAST_SITE_VALIDATION_STRATEGY' => dast_site_validation.validation_strategy,
                'DAST_SITE_VALIDATION_TOKEN' => dast_site_validation.dast_site_token.token,
                'DAST_SITE_VALIDATION_URL' => dast_site_validation.validation_url
              },
              'script' => ['~/validate.sh']
            }
          }
        end

        def dast_site_validation
          @dast_site_validation ||= params[:dast_site_validation]
        end
      end
    end
  end
end

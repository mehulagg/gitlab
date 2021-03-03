# frozen_string_literal: true

module Security
  module CiConfiguration
    module ApiFuzzing
      class CreateService < ::BaseContainerService
        def create
          success(yaml: preset_configuration.merge({ 'variables' => variables }))
        end

        private

        def preset_configuration
          {
            'stages' => ['fuzz'],
            'include' => [{ 'template' => 'API-Fuzzing.gitlab-ci.yml' }]
          }
        end

        def variables
          { 'FUZZAPI_TARGET_URL' => params[:target] }
            .merge(api_specification_file)
            .merge(optional_variables)
        end

        def api_specification_file
          if params[:scan_mode] == 'HAR'
            { 'FUZZAPI_HAR' => params[:api_specification_file] }
          else
            { 'FUZZAPI_OPENAPI' => params[:api_specification_file] }
          end
        end

        def optional_variables
          optionals = {}

          if params[:auth_password]
            optionals['FUZZAPI_HTTP_PASSWORD'] = params[:auth_password]
          end

          if params[:auth_username]
            optionals['FUZZAPI_HTTP_USERNAME'] = params[:auth_username]
          end

          if params[:scan_profile]
            optionals['FUZZAPI_PROFILE'] = params[:scan_profile]
          end

          optionals
        end
      end
    end
  end
end

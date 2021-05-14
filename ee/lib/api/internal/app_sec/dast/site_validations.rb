# frozen_string_literal: true

module API
  module Internal
    module AppSec
      module Dast
        class SiteValidations < ::API::Base
          feature_category :dynamic_application_security_testing

          namespace :internal do
            namespace :dast do
              resource :site_validations do
                desc 'Transition a DAST site validation.' do
                  detail 'Transitions a DAST site validation to a new state.'
                end
                params do
                  requires :event, type: String, desc: 'The transition event.'
                end
                put ':id/transition' do
                  validation = DastSiteValidation.find(params[:id])

                  success = case params[:event]
                            when 'start'
                              validation.start
                            when 'fail_op'
                              validation.fail_op
                            when 'retry'
                              validation.retry
                            when 'pass'
                              validation.pass
                            end

                  render_api_error!('Could not update DAST site validation', 400) unless success

                  status 200, { state: validation.state }
                end
              end
            end
          end
        end
      end
    end
  end
end

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
                desc 'Update a DAST site validation.' do
                  detail 'Transitions a DAST site validation to a new state.'
                end
                params do
                  requires :state, type: String, desc: 'The new state to transition to.'
                end
                put ':id' do
                  validation = DastSiteValidation.find(params[:id])

                  case params[:state]
                  when 'start'
                    validation.start
                  when 'retry'
                    validation.retry
                  when 'fail'
                    validation.fail_op
                  when 'pass'
                    validation.pass
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

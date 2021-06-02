# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Seed
          module Build
            extend ::Gitlab::Utils::Override

            override :attributes
            def attributes
              super.deep_merge(dast_attributes)
            end

            private

            # rubocop:disable Gitlab/ModuleWithInstanceVariables
            def dast_attributes
              return {} unless @seed_attributes[:stage] == 'dast'
              return {} unless ::Feature.enabled?(:dast_configuration_ui, @pipeline.project)

              result = AppSec::Dast::Variables::FetchService.new(
                container: @pipeline.project,
                params: {
                  dast_site_profile: fetch_job_variable('DAST_SITE_PROFILE'),
                  dast_scanner_profile: fetch_job_variable('DAST_SCANNER_PROFILE')
                }
              ).execute

              return {} unless result.success?

              result.payload
            end
            # rubocop:enable Gitlab/ModuleWithInstanceVariables

            # rubocop:disable Gitlab/ModuleWithInstanceVariables
            def fetch_job_variable(key)
              return unless @job_variables

              @job_variables
                .find {|var| var[:key] == key }
                &.fetch(:value)
            end
            # rubocop:enable Gitlab/ModuleWithInstanceVariables
          end
        end
      end
    end
  end
end

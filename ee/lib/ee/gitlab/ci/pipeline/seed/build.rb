# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Seed
          module Build
            extend ::Gitlab::Utils::Override

            override :attributes
            def initialize(context, attributes, previous_stages)
              super

              @dast_configuration = attributes.dig(:options, :dast_configuration)
            end

            override :attributes
            def attributes
              super.deep_merge(dast_attributes)
            end

            private

            # rubocop:disable Gitlab/ModuleWithInstanceVariables
            def dast_attributes
              return {} unless @dast_configuration
              return {} unless @seed_attributes[:stage] == 'dast'
              return {} unless ::Feature.enabled?(:dast_configuration_ui, @pipeline.project, default_enabled: :yaml)

              result = AppSec::Dast::Profiles::BuildConfigService.new(
                project: @pipeline.project,
                current_user: @pipeline.user,
                params: {
                  dast_site_profile: @dast_configuration[:site_profile],
                  dast_scanner_profile: @dast_configuration[:scanner_profile]
                }
              ).execute

              return {} unless result.success?

              result.payload
            end
            # rubocop:enable Gitlab/ModuleWithInstanceVariables
          end
        end
      end
    end
  end
end

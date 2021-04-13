# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module SecurityOrchestrationPolicies
        class Processor
          def initialize(config, project, ref)
            @config = config
            @project = project
            @ref = ref
          end

          def perform
            return @config unless project&.feature_available?(:security_orchestration_policies)
            return @config unless security_orchestration_policy_configuration&.enabled?

            @config
              .deep_merge(on_demand_scans_template)
          end

          def on_demand_scans_template
            ::Security::SecurityOrchestrationPolicies::OnDemandScanPipelineConfigurationService
              .new(project)
              .execute(security_orchestration_policy_configuration.on_demand_scan_actions(@ref))
          end

          private

          attr_reader :project

          delegate :security_orchestration_policy_configuration, to: :project, allow_nil: true
        end
      end
    end
  end
end

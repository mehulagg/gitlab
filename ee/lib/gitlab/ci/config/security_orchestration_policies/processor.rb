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
            @start = Time.now.utc
          end

          def perform
            return @config unless project&.feature_available?(:security_orchestration_policies)
            return @config unless security_orchestration_policy_configuration&.enabled?

            merged_config = @config.deep_merge(on_demand_scans_template)
            observe_processing_duration(Time.now.utc - @start)

            merged_config
          end

          def on_demand_scans_template
            ::Security::SecurityOrchestrationPolicies::OnDemandScanPipelineConfigurationService
              .new(project)
              .execute(security_orchestration_policy_configuration.on_demand_scan_actions(@ref))
          end

          private

          attr_reader :project

          delegate :security_orchestration_policy_configuration, to: :project, allow_nil: true

          def observe_processing_duration(duration)
            ::Gitlab::Ci::Pipeline::Metrics
              .pipeline_security_orchestration_policy_processing_duration_histogram
              .observe({}, duration.seconds)
          end
        end
      end
    end
  end
end

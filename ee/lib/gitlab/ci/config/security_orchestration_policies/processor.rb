# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module SecurityOrchestrationPolicies
        class Processor
          attr_reader :project, :warnings

          delegate :security_orchestration_policy_configuration, to: :project, allow_nil: true

          def initialize(config, project, ref)
            @config = config
            @project = project
            @ref = ref
            @warnings = []
          end

          def perform
            return @config unless project&.feature_available?(:security_orchestration_policies)
            return @config unless security_orchestration_policy_configuration&.enabled?

            validate_policy_configuration!
            return @config if @warnings.present?

            @config.deep_merge(on_demand_scans_template)
          end

          private

          def on_demand_scans_template
            configuration_service = ::Security::SecurityOrchestrationPolicies::OnDemandScanPipelineConfigurationService.new(project)
            template = configuration_service.execute(security_orchestration_policy_configuration.on_demand_scan_actions(@ref))

            @warnings += configuration_service.warnings

            template
          end

          def validate_policy_configuration!
            if !security_orchestration_policy_configuration.policy_configuration_exists?
              @warnings << _('scan-execution-policy: policy not applied, %{policy_path} file is missing') % { policy_path: Security::OrchestrationPolicyConfiguration::POLICY_PATH }
            elsif !security_orchestration_policy_configuration.policy_configuration_valid?
              @warnings << _('scan-execution-policy: policy not applied, %{policy_path} file is invalid') % { policy_path: Security::OrchestrationPolicyConfiguration::POLICY_PATH }
            end
          end
        end
      end
    end
  end
end

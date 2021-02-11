# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module SecurityOrchestrationPolicies
        class Processor
          RequiredError = Class.new(StandardError)

          def initialize(config, project, ref)
            @config = config
            @project = project
            @ref = ref
          end

          def perform
            return @config unless project.feature_available?(:security_orchestration_policies)
            return @config unless security_orchestration_policy_configuration&.enabled?

            @config
              .deep_merge(merged_security_orchestration_policy_templates)
              .deep_merge(on_demand_scans_template)
          end

          def merged_security_orchestration_policy_templates
            security_orchestration_policy_configuration
              .scan_templates(@ref)
              .reduce({}) { |config, template_name| config.deep_merge(required_template_hash(template_name)) }
              .then { |config| Config::Extendable.new(config).to_hash }
          end

          def on_demand_scans_template
            ::Security::SecurityOrchestrationPolicies::OnDemandScanPipelineConfigurationService
              .new(project)
              .execute(security_orchestration_policy_configuration.on_demand_scan_actions(@ref))
          end

          private

          attr_reader :project

          delegate :security_orchestration_policy_configuration, to: :project

          def required_template_hash(template_name)
            template = required_template(template_name)
            raise RequiredError, "Security Orchestration Policy required template '#{template_name}' not found!" unless template

            Gitlab::Config::Loader::Yaml.new(template.content).load!
          end

          def required_template(template_name)
            ::TemplateFinder.build(:gitlab_ci_ymls, nil, name: template_name).execute
          end
        end
      end
    end
  end
end

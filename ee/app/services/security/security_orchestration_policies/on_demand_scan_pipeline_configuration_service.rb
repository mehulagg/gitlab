# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class OnDemandScanPipelineConfigurationService
      def initialize(project)
        @project = project
      end

      def execute(actions)
        actions
          .map.with_index { |action, index| prepare_child_policy_configuration(action, index) }
          .reduce({}, :merge)
      end

      private

      attr_reader :project

      def prepare_child_policy_configuration(action, index)
        {
          "security_orchestration_policy_on_demand_#{index}" => prepare_on_demand_scan_configuration(action)
        }.deep_symbolize_keys
      end

      def prepare_on_demand_scan_configuration(action)
        result = prepare_on_demand_scan_params(action[:site_profile], action[:scan_profile])
        return error_script(result.message) unless result.success?

        ci_configuration = YAML.safe_load(::Ci::DastScanCiConfigurationService.new(@project).execute(result.payload[:params]))

        {
          'variables' => ci_configuration['variables'],
          'trigger' => {
            'include' => ci_configuration['include']
          }
        }
      end

      def prepare_on_demand_scan_params(site_profile_name, scan_profile_name)
        site_profile = DastSiteProfilesFinder.new(project_id: project.id, name: site_profile_name).execute.first
        scanner_profile = DastScannerProfilesFinder.new(project_ids: [project.id], name: scan_profile_name).execute.first

        DastOnDemandScans::ParamsCreateService
          .new(container: @project, params: { dast_site_profile: site_profile, dast_scanner_profile: scanner_profile })
          .execute
      end

      def error_script(error_message)
        {
          'script' => "echo \"Error during On-Demand Scan execution: #{error_message}\" && false",
          'allow_failure' => true
        }
      end
    end
  end
end

# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class OnDemandScanPipelineConfigurationService
      include Gitlab::Utils::StrongMemoize

      attr_reader :project, :warnings

      def initialize(project)
        @project = project
        @warnings = []
      end

      def execute(actions)
        actions
          .map.with_index { |action, index| prepare_policy_configuration(action, index) }
          .reduce({}, :merge)
      end

      private

      DAST_ON_DEMAND_TEMPLATE_NAME = 'DAST-On-Demand-Scan'

      def prepare_policy_configuration(action, index)
        {
          "dast-on-demand-#{index}" => prepare_on_demand_scan_configuration(action, index)
        }.compact.deep_symbolize_keys
      end

      def prepare_on_demand_scan_configuration(action, index)
        result = prepare_on_demand_scan_params(action[:site_profile], action[:scanner_profile])

        unless result.success?
          @warnings << _('scan-execution-policy-%{index}: %{error_message}') % { index: index, error_message: result.message }
          return
        end

        ci_configuration = YAML.safe_load(::Ci::DastScanCiConfigurationService.execute(result.payload))

        dast_on_demand_template[:dast].deep_merge(
          'variables' => dast_on_demand_template[:variables].deep_merge(ci_configuration['variables']),
          'stage' => 'test'
        )
      end

      def prepare_on_demand_scan_params(site_profile_name, scanner_profile_name)
        site_profile = DastSiteProfilesFinder.new(project_id: project.id, name: site_profile_name).execute.first
        scanner_profile = DastScannerProfilesFinder.new(project_ids: [project.id], name: scanner_profile_name).execute.first if scanner_profile_name.present?

        DastOnDemandScans::ParamsCreateService
          .new(container: project, params: { dast_site_profile: site_profile, dast_scanner_profile: scanner_profile })
          .execute
      end

      def dast_on_demand_template
        strong_memoize(:dast_on_demand_template) do
          template = ::TemplateFinder.build(:gitlab_ci_ymls, nil, name: DAST_ON_DEMAND_TEMPLATE_NAME).execute
          Gitlab::Config::Loader::Yaml.new(template.content).load!
        end
      end
    end
  end
end

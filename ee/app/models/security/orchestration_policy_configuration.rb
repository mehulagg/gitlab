# frozen_string_literal: true

module Security
  class OrchestrationPolicyConfiguration < ApplicationRecord
    self.table_name = 'security_orchestration_policy_configurations'

    POLICIES_BASE_PATH = '.gitlab/security-policies/'

    SCAN_TEMPLATES = {
      'api_fuzzing'         => 'API-Fuzzing',
      'container_scanning'  => 'Container-Scanning',
      'coverage_fuzzing'    => 'Coverage-Fuzzing',
      'dependency_scanning' => 'Dependency-Scanning',
      'license_scanning'    => 'License-Scanning',
      'sast'                => 'SAST',
      'secret_detection'    => 'Secret-Detection'
    }.freeze

    ON_DEMAND_SCANS = %w[dast].freeze

    belongs_to :project, inverse_of: :security_orchestration_policy_configuration
    belongs_to :security_policy_management_project, class_name: 'Project', foreign_key: 'security_policy_management_project_id'

    validates :project, presence: true, uniqueness: true
    validates :security_policy_management_project, presence: true, uniqueness: true

    def enabled?
      ::Feature.enabled?(:security_orchestration_policies_configuration, project, default_enabled: :yaml)
    end

    def active_policies
      security_policy_management_project
        .repository
        .ls_files(security_policy_management_project.default_branch)
        .grep(/\A#{Regexp.escape(POLICIES_BASE_PATH)}.+\.(yml|yaml)\z/)
        .map { |path| policy_at(path) }
        .select { |config| config[:enabled] }
    end

    def policy_at(path)
      security_policy_management_project
        .repository
        .blob_data_at(security_policy_management_project.default_branch, path)
        .then { |config| Gitlab::Config::Loader::Yaml.new(config).load! }
    end

    def scan_templates(branch)
      active_policies
        .select { |policy| applicable_for_branch?(policy, branch) }
        .flat_map { |policy| policy[:actions].pluck(:scan) }
        .uniq
        .then { |scans| SCAN_TEMPLATES.values_at(*scans) }
        .compact
    end

    def on_demand_scan_actions(branch)
      active_policies
        .select { |policy| applicable_for_branch?(policy, branch) }
        .flat_map { |policy| policy[:actions] }
        .select { |action| action[:scan].in?(ON_DEMAND_SCANS) }
    end

    private

    def applicable_for_branch?(policy, ref)
      policy[:rules].any? do |rule|
        rule[:type] == 'pipeline' && rule[:branches].any? { |branch| wildcard_regex(branch).match?(ref) }
      end
    end

    def wildcard_regex(branch)
      name = branch.gsub('*', 'STAR_DONT_ESCAPE')
      quoted_name = Regexp.quote(name)
      regex_string = quoted_name.gsub('STAR_DONT_ESCAPE', '.*?')
      /\A#{regex_string}\z/
    end
  end
end

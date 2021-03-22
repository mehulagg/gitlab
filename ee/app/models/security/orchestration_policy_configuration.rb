# frozen_string_literal: true

module Security
  class OrchestrationPolicyConfiguration < ApplicationRecord
    include Gitlab::Utils::StrongMemoize

    self.table_name = 'security_orchestration_policy_configurations'

    POLICIES_BASE_PATH = '.gitlab/security-policies/'

    ON_DEMAND_SCANS = %w[dast].freeze

    belongs_to :project, inverse_of: :security_orchestration_policy_configuration
    belongs_to :security_policy_management_project, class_name: 'Project', foreign_key: 'security_policy_management_project_id'

    validates :project, presence: true, uniqueness: true
    validates :security_policy_management_project, presence: true

    def enabled?
      ::Feature.enabled?(:security_orchestration_policies_configuration, project)
    end

    def active_policies
      return [] unless enabled?

      security_policy_management_project
        .repository
        .ls_files(security_policy_management_project.default_branch_or_master)
        .grep(/\A#{Regexp.escape(POLICIES_BASE_PATH)}.+\.(yml|yaml)\z/)
        .map { |path| policy_at(path) }
        .select { |config| config[:enabled] }
    end

    def on_demand_scan_actions(branch)
      active_policies
        .select { |policy| applicable_for_branch?(policy, branch) }
        .flat_map { |policy| policy[:actions] }
        .select { |action| action[:scan].in?(ON_DEMAND_SCANS) }
    end

    def active_policy_names_with_dast_site_profile(profile_name)
      active_policy_names_with_dast_profiles.dig(:site_profiles, profile_name)
    end

    def active_policy_names_with_dast_scanner_profile(profile_name)
      active_policy_names_with_dast_profiles.dig(:scanner_profiles, profile_name)
    end

    private

    def active_policy_names_with_dast_profiles
      strong_memoize(:active_policy_names_with_dast_profiles) do
        profiles = { site_profiles: Hash.new { Set.new }, scanner_profiles: Hash.new { Set.new } }

        active_policies.each do |policy|
          policy[:actions].each do |action|
            next unless action[:scan].in?(ON_DEMAND_SCANS)

            profiles[:site_profiles][action[:site_profile]] += [policy[:name]]
            profiles[:scanner_profiles][action[:scanner_profile]] += [policy[:name]] if action[:scanner_profile].present?
          end
        end

        profiles
      end
    end

    def policy_at(path)
      security_policy_management_project
        .repository
        .blob_data_at(security_policy_management_project.default_branch_or_master, path)
        .then { |config| Gitlab::Config::Loader::Yaml.new(config).load! }
    end

    def applicable_for_branch?(policy, ref)
      policy[:rules].any? do |rule|
        rule[:type] == 'pipeline' && rule[:branches].any? { |branch| RefMatcher.new(branch).matches?(ref) }
      end
    end
  end
end

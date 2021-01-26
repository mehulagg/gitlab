# frozen_string_literal: true

module Security
  class OrchestrationPolicyConfiguration < ApplicationRecord
    self.table_name = 'security_orchestration_policy_configurations'

    belongs_to :project
    belongs_to :security_policy_management_project, class_name: 'Project', foreign_key: 'security_policy_management_project_id'

    delegate :security_orchestration_policy_projects, to: :security_policy_management_project

    def active_policies
      security_policy_management_project
        .repository
        .ls_files(security_policy_management_project.default_branch)
        .select { |path| path.starts_with?('.gitlab/security-policies/') }
        .map { |path| [path, policy_at(path)] }
        .select { |(_, config)| config['enabled'] }
    end

    def policy_at(path)
      security_policy_management_project
        .repository
        .blob_data_at(security_policy_management_project.default_branch, path)
        .then { |config| YAML.safe_load(config, [Symbol], [], true) }
    end
  end
end

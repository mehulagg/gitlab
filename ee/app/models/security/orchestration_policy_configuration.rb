# frozen_string_literal: true

module Security
  class OrchestrationPolicyConfiguration < ApplicationRecord
    self.table_name = 'security_orchestration_policy_configurations'

    belongs_to :project, inverse_of: :security_orchestration_policy_configuration
    belongs_to :security_policy_management_project, class_name: 'Project', foreign_key: 'security_policy_management_project_id'

    validates :project, presence: true, uniqueness: true
    validates :security_policy_management_project, presence: true, uniqueness: true
  end
end

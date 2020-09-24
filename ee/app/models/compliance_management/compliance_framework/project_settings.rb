# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    class ProjectSettings < ApplicationRecord
      self.table_name = 'project_compliance_framework_settings'
      self.primary_key = :project_id

      delegate :name, to: :framework

      belongs_to :project
      belongs_to :framework, class_name: 'ComplianceManagement::Framework'

      validates :project, presence: true
    end
  end
end

# frozen_string_literal: true

require_dependency 'compliance_management/compliance_framework'

module ComplianceManagement
  module ComplianceFramework
    class ProjectSettings < ApplicationRecord
      self.table_name = 'project_compliance_framework_settings'
      self.primary_key = :project_id

      belongs_to :project
      belongs_to :compliance_management_framework, class_name: "ComplianceManagement::Framework", foreign_key: :framework_id

      enum framework: ::ComplianceManagement::ComplianceFramework::FRAMEWORKS

      validates :project, presence: true
      validates :framework, uniqueness: { scope: [:project_id] }
      validates :framework, inclusion: { in: self.frameworks.keys }

      before_save :ensure_compliance_framework_record

      private

      # Temporary callback for compatibility.
      # This keeps the ComplianceManagement::Framework table in-sync with the `framework` enum column.
      # At a later point the enum column will be removed so we can support custom frameworks.
      def ensure_compliance_framework_record
        framework_params = ComplianceManagement::ComplianceFramework::ENUM_FRAMEWORK_MAPPING[self.class.frameworks[framework]]
        root_namespace = project.namespace.root_ancestor

        # Framework is associated with the root group, there could be a case where the framework is already
        # there. Using safe_find_or_create_by is not enough because some attributes (color) could be changed on the framework record, however
        # the name is unique. For now we try to create the record and rescue RecordNotUnique error.
        ComplianceManagement::Framework.create(framework_params.merge(namespace_id: root_namespace.id)) rescue ActiveRecord::RecordNotUnique

        # We're sure that the framework record exists.
        self.compliance_management_framework = ComplianceManagement::Framework.find_by!(namespace_id: root_namespace.id, name: framework_params[:name])
      end
    end
  end
end

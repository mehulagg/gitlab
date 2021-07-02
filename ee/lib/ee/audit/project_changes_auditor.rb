# frozen_string_literal: true

module EE
  module Audit
    class ProjectChangesAuditor < BaseChangesAuditor
      def execute
        audit_changes(:visibility_level, as: 'visibility', model: model)
        audit_changes(:path, as: 'path', model: model)
        audit_changes(:name, as: 'name', model: model)
        audit_changes(:namespace_id, as: 'namespace', model: model)
        audit_changes(:repository_size_limit, as: 'repository_size_limit', model: model)
        audit_changes(:packages_enabled, as: 'packages_enabled', model: model)

        audit_changes(:merge_requests_author_approval, as: 'prevent merge request approval from authors', model: model)
        audit_changes(:merge_requests_disable_committers_approval, as: 'prevent merge request approval from reviewers', model: model)

        audit_project_feature_changes
        audit_compliance_framework_changes

      end

      private

      def audit_compliance_framework_changes
        if model&.compliance_framework_setting&.destroyed?

          audit_context = {
            author: @current_user,
            scope: model,
            target: model,
            message: "Unassigned project compliance framework"
          }

          ::Gitlab::Audit::Auditor.audit(audit_context)
        end

        audit_changes(:framework_id, as: 'compliance framework', model: model.compliance_framework_setting, entity: model)
      end

      def audit_project_feature_changes
        ::EE::Audit::ProjectFeatureChangesAuditor.new(@current_user, model.project_feature, model).execute
      end

      def attributes_from_auditable_model(column)
        case column
        when :name
          {
            from: model.namespace.human_name + ' / ' + model.previous_changes[column].first.to_s,
            to: model.full_name
          }
        when :path
          {
            from: model.old_path_with_namespace.to_s,
            to: model.full_path
          }
        when :visibility_level
          {
            from:  ::Gitlab::VisibilityLevel.level_name(model.previous_changes[column].first),
            to: ::Gitlab::VisibilityLevel.level_name(model.previous_changes[column].last)
          }
        when :namespace_id
          {
            from: model.old_path_with_namespace,
            to: model.full_path
          }
        when :merge_requests_author_approval
          {
            from: !model.previous_changes[column].first,
            to: !model.previous_changes[column].last
          }
        when :framework_id
          old_framework_name = ComplianceManagement::Framework.where(id: model.previous_changes["framework_id"].first).first&.name || "None"

          {
            from: old_framework_name,
            to: ComplianceManagement::Framework.find(model.previous_changes["framework_id"].last).name
          }
        else
          {
            from: model.previous_changes[column].first,
            to: model.previous_changes[column].last
          }
        end.merge(target_details: model.full_path)
      end
    end
  end
end

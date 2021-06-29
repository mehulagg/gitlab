# frozen_string_literal: true

module Projects
  module Security
    class PoliciesController < Projects::ApplicationController
      include SecurityAndCompliancePermissions

      before_action do
        push_frontend_feature_flag(:security_orchestration_policies_configuration, project)
        check_permissions!
      end

      feature_category :security_orchestration

      def show
        assigned_policy_id = project&.security_orchestration_policy_configuration&.security_policy_management_project_id
        assigned_policy_name = assigned_policy_id ? Project.find(assigned_policy_id)&.name : ''
        assigned_policy_gid = "gid://gitlab/Project/#{assigned_policy_id}"
        @assigned_policy_project = { id: assigned_policy_gid, name: assigned_policy_name }

        render :show
      end

      private

      def check_permissions!
        render_404 unless Feature.enabled?(:security_orchestration_policies_configuration, project) && can?(current_user, :security_orchestration_policies, project)
      end
    end
  end
end

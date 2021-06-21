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
        @assigned_policy_project = { id: assigned_policy_id, name: assigned_policy_name }

        render :show
      end

      def assign
        result = ::Security::Orchestration::AssignService.new(project, nil, policy_project_id: policy_project_params[:policy_project_id]).execute

        if result.success?
          flash[:notice] = _('Operation completed')
        else
          flash[:alert] = result.message
        end

        redirect_to project_security_policy_url(project)
      end

      private

      def check_permissions!
        render_404 unless Feature.enabled?(:security_orchestration_policies_configuration, project) && can?(current_user, :security_orchestration_policies, project)
      end

      def policy_project_params
        params.require(:orchestration).permit(:policy_project_id)
      end
    end
  end
end

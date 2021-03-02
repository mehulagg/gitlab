# frozen_string_literal: true

module Projects
  module Security
    class PoliciesController < Projects::ApplicationController
      include SecurityAndCompliancePermissions

      before_action do
        push_frontend_feature_flag(:security_orchestration_policies_configuration, project)
      end

      feature_category :security_orchestration

      def show
        render_404 unless Feature.enabled?(:security_orchestration_policies_configuration, project) && can?(current_user, :security_orchestration_policies, project)
      end
    end
  end
end

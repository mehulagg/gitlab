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

      # arams {"utf8"=>"✓", "authenticity_token"=>"LYYIbIqd2gBMMP2Wjy+Q2JhhXZ4TFps0BW3t+cslPOadSoK7e13efQ9VFtyZxMzyJXYWtmD66mWrjbg/P3JDQQ==", "orchestration"=>{"management_project_id"=>"21"}, "controller"=>"projects/security/policies", "action"=>"assign", "namespace_id"=>"root", "project_id"=>"alpine"}
      # Project 23
      def assign
      end
    end
  end
end

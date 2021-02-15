# frozen_string_literal: true

module Projects
  module Security
    class PolicyController < Projects::ApplicationController
      include SecurityAndCompliancePermissions

      before_action do
        push_frontend_feature_flag(:security_orchestration_policies_configuration, project)
      end

      feature_category :security_orchestration

      def index
        render_404 unless Feature.enabled?(:threat_monitoring_alerts, project)
      end
    end
  end
end
# frozen_string_literal: true

module Projects
  module Security
    class DashboardController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      before_action only: [:index] do
        push_frontend_feature_flag(:security_auto_fix, project, default_enabled: false)
      end

      feature_category :static_application_security_testing
    end
  end
end

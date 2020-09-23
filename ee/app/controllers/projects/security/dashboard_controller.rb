# frozen_string_literal: true

module Projects
  module Security
    class DashboardController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      before_action only: [:index] do
        push_frontend_feature_flag(:hide_dismissed_vulnerabilities)
        push_frontend_feature_flag(:scanner_alerts, default_enabled: true)
      end
    end
  end
end

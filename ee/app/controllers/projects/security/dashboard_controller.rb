# frozen_string_literal: true

module Projects
  module Security
    class DashboardController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

    end
  end
end

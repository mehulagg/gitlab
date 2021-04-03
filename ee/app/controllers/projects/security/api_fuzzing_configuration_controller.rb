# frozen_string_literal: true

module Projects
  module Security
    class ApiFuzzingConfigurationController < Projects::ApplicationController
      include SecurityAndCompliancePermissions
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      feature_category :fuzz_testing

      def show
      end
    end
  end
end

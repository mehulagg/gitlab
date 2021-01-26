# frozen_string_literal: true

module Projects
  module Security
    class ApiFuzzingConfigurationController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      feature_category :fuzz_testing

      def show
        not_found unless Feature.enabled?(:api_fuzzing_configuration_ui, @project, default_enabled: :yaml)
      end
    end
  end
end

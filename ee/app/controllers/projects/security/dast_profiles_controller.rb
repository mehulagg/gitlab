# frozen_string_literal: true

module Projects
  module Security
    class DastProfilesController < Projects::ApplicationController
      before_action do
        authorize_read_on_demand_scans!
        push_frontend_feature_flag(:security_on_demand_scans_site_validation, @project, default_enabled: :yaml)
        push_frontend_feature_flag(:dast_saved_scans, @project, default_enabled: :yaml)
      end

      feature_category :dynamic_application_security_testing

      def show
      end
    end
  end
end

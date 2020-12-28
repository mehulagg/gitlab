# frozen_string_literal: true

module Projects
  class OnDemandScansController < Projects::ApplicationController
    before_action do
      authorize_read_on_demand_scans!
      push_frontend_feature_flag(:security_dast_site_profiles_additional_fields, @project, default_enabled: :yaml)
    end

    feature_category :dynamic_application_security_testing

    def index
    end
  end
end

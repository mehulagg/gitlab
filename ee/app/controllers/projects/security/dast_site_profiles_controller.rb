# frozen_string_literal: true

module Projects
  module Security
    class DastSiteProfilesController < Projects::ApplicationController
      include SecurityAndCompliancePermissions

      before_action do
        authorize_read_on_demand_scans!
        push_frontend_feature_flag(:security_dast_site_profiles_additional_fields, @project, default_enabled: :yaml)
      end

      feature_category :dynamic_application_security_testing

      def new
      end

      def edit
        @site_profile = Dast::SiteProfilePresenter.new(
          DastSiteProfilesFinder.new(project_id: @project.id, id: params[:id]).execute.first! # rubocop: disable CodeReuse/ActiveRecord
        )
      end
    end
  end
end

# frozen_string_literal: true

module Projects
  module Security
    class DastSiteProfilesController < Projects::ApplicationController
      before_action do
        authorize_read_on_demand_scans!
        push_frontend_feature_flag(:security_on_demand_scans_site_validation, @project)
      end

      def new
      end

      def edit
        @site_profile = DastSiteProfilesFinder.new(project_id: @project.id, id: params[:id]).execute.first! # rubocop: disable CodeReuse/ActiveRecord
      end
    end
  end
end

# frozen_string_literal: true

module Projects
  module Security
    class DastSiteProfilesController < Projects::ApplicationController
      before_action :authorize_read_on_demand_scans!

      feature_category :dynamic_application_security_testing

      def new
      end

      def edit
        @site_profile = DastSiteProfilesFinder.new(project_id: @project.id, id: params[:id]).execute.first! # rubocop: disable CodeReuse/ActiveRecord
      end
    end
  end
end

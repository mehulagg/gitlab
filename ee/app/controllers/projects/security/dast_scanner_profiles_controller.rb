# frozen_string_literal: true

module Projects
  module Security
    class DastScannerProfilesController < Projects::ApplicationController
      before_action :authorize_read_on_demand_scans!

      feature_category :dynamic_application_security_testing

      def new
      end

      def edit
        @scanner_profile = @project
          .dast_scanner_profiles
          .find(params[:id])
      end
    end
  end
end

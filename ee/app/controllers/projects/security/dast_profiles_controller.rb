# frozen_string_literal: true

module Projects
  module Security
    class DastProfilesController < Projects::ApplicationController
      before_action :authorize_read_on_demand_scans!
      before_action do
        push_frontend_feature_flag(:security_on_demand_scans_scanner_profiles, project, default_enabled: true)
      end

      def show
      end
    end
  end
end

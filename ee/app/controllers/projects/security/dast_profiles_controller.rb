# frozen_string_literal: true

module Projects
  module Security
    class DastProfilesController < Projects::ApplicationController
      before_action do
        authorize_read_on_demand_scans!
      end

      feature_category :dynamic_application_security_testing

      def show
      end
    end
  end
end

# frozen_string_literal: true

module Projects
  class OnDemandScansController < Projects::ApplicationController
    before_action :authorize_read_on_demand_scans!

    feature_category :dynamic_application_security_testing

    def index
    end
  end
end

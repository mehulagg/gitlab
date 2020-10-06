# frozen_string_literal: true

module Projects
  class OnDemandScansController < Projects::ApplicationController
    before_action :authorize_read_on_demand_scans!

    def index
    end
  end
end

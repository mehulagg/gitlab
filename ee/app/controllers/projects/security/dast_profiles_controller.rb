# frozen_string_literal: true

module Projects
  module Security
    class DastProfilesController < Projects::ApplicationController
      before_action :authorize_read_on_demand_scans!

      def show
      end
    end
  end
end

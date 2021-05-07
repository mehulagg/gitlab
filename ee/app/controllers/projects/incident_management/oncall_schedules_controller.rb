# frozen_string_literal: true

module Projects
  module IncidentManagement
    class OncallSchedulesController < Projects::ApplicationController
      before_action :authorize_read_incident_management_oncall_schedule!
      before_action do
        push_frontend_feature_flag(:multiple_oncall_schedules, @project)
      end

      feature_category :incident_management

      def index
      end
    end
  end
end

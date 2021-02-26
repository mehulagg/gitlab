# frozen_string_literal: true

module Projects
  module IncidentManagement
    class OncallSchedulesController < Projects::ApplicationController
      before_action :authorize_read_incident_management_oncall_schedule!

      feature_category :incident_management

      before_action do
        push_frontend_feature_flag(:oncall_schedules_mvc_edit_rotations, default_enabled: false)
      end

      def index
      end
    end
  end
end

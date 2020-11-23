# frozen_string_literal: true

module Projects
  module IncidentManagement
    class OncallSchedulesController < Projects::ApplicationController
      before_action :ensure_oncall_schedules_available!
      before_action :authorize_read_incident_management_oncall_schedule!

      def index
      end

      private

      def ensure_oncall_schedules_available!
        render_404 unless available?
      end

      def available?
        Feature.enabled?(:oncall_schedules_mvc, project) &&
          project.feature_available?(:oncall_schedules)
      end
    end
  end
end

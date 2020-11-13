# frozen_string_literal: true

module IncidentManagement
  class OncallSchedulesFinder
    def initialize(current_user, project, params = {})
      @current_user = current_user
      @project = project
      @params = params
    end

    def execute
      return IncidentManagement::OncallSchedule.none unless available? && allowed?

      project.incident_management_oncall_schedules
    end

    private

    attr_reader :current_user, :project, :params

    def available?
      project.feature_available?(:oncall_schedules)
    end

    def allowed?
      Ability.allowed?(current_user, :read_incident_management_oncall_schedule, project)
    end
  end
end

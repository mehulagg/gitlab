# frozen_string_literal: true

module IncidentManagement
  class OncallSchedulesFinder
    def initialize(current_user, project, params = {})
      @current_user = current_user
      @project = project
      @params = params
    end

    def execute
      return IncidentManagement::OncallSchedule.none unless allowed?

      collection = project.incident_management_oncall_schedules
      by_iid(collection)
    end

    private

    attr_reader :current_user, :project, :params

    def allowed?
      Ability.allowed?(current_user, :read_incident_management_oncall_schedule, project)
    end

    def by_iid(collection)
      return collection unless params[:iid]

      collection.for_iid(params[:iid])
    end
  end
end

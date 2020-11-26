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

      @schedules = project.incident_management_oncall_schedules
      schedules = by_iid(params[:iids])

      schedules
    end

    private

    attr_reader :current_user, :project, :params, :schedules

    def available?
      Feature.enabled?(:oncall_schedules_mvc, project) &&
        project.feature_available?(:oncall_schedules)
    end

    def allowed?
      Ability.allowed?(current_user, :read_incident_management_oncall_schedule, project)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def by_iid(iids)
      iids.present? ? schedules.where(iid: iids) : schedules
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end

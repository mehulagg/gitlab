# frozen_string_literal: true

module IncidentManagement
  class OncallRotationsFinder
    def initialize(current_user, project, schedule, params = {})
      @current_user = current_user
      @project = project
      @schedule = schedule
      @params = params
    end

    def execute
      return IncidentManagement::OncallRotation.none unless schedule && allowed?

      collection = schedule.rotations
      by_id(collection)
    end

    private

    attr_reader :current_user, :schedule, :project, :params

    def allowed?
      Ability.allowed?(current_user, :read_incident_management_oncall_schedule, project)
    end

    def by_id(collection)
      return collection unless params[:id]

      collection.id_in(params[:id])
    end
  end
end

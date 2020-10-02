# frozen_string_literal: true

module IncidentManagement
  class CreateSlaService < BaseService
    def initialize(incident, current_user, project)
      super(incident.project, current_user) # TODO do we need this?

      @incident = incident
      @project = project
    end

    def execute
      return unless ::Feature.enabled?(:incident_sla_dev, @project) && project.feature_available?(:incident_sla, current_user)
      return unless incident_setting&.sla_timer?

      sla = incident.build_incident_sla(
        due_at: incident.created_at + incident_setting.sla_timer_minutes.minutes
      )

      return sla if sla.save
      return error(sla.errors)
    end

    attr_reader :incident

    private

    def incident_setting
      @incident_setting ||= project.incident_management_setting
    end
  end
end
